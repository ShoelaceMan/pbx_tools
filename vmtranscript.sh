#!/bin/sh

# set PATH
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# save the current directory
pushd .
 
# create a temporary directory and cd to it
TMPDIR=$(mktemp -d)
cd $TMPDIR
 
# dump the stream to a temporary file
cat >> stream.org
 
# get the boundary
BOUNDARY=$(grep "boundary=" stream.org | cut -d'"' -f 2)
 
# if mail has no boundaries, assume no attachment
if [ "$BOUNDARY" = "" ]
	
then
	# send the original stream
	mv stream.org stream.new
else
	# cut the original stream into parts
	# stream.part  - header before the boundary
	# stream.part1 - header after the bounday
	# stream.part2 - body of the message
	# stream.part3 - attachment in base64 (WAV file)
	# stream.part4 - footer of the message
	awk '/'$BOUNDARY'/{i++}{print > "stream.part"i}' stream.org
 
	# cut the attachment into parts
	# stream.part3.head - header of attachment
	# stream.part3.wav.base64 - wav file of attachment (encoded base64)
	sed '7,$d' stream.part3 > stream.part3.wav.head
	sed '1,6d' stream.part3 > stream.part3.wav.base64

	# convert the base64 file to a wav file
	dos2unix -o stream.part3.wav.base64
	base64 -di stream.part3.wav.base64 > stream.part3.wav

	# convert the wav file to FLAC
	# sox -G stream.part3.wav --channels=1 --bits=16 --rate=8000 stream.part3.flac trim 0 59

	# convert to MP3
	sox stream.part3.wav stream.part3-pcm.wav
	lame -m m -b 24 stream.part3-pcm.wav stream.part3.mp3 
	base64 stream.part3.mp3 > stream.part3.mp3.base64

	# create mp3 mail part
	sed 's/x-[wW][aA][vV]/mpeg/g' stream.part3.wav.head | sed 's/.[wW][aA][vV]/.mp3/g' > stream.part3.new
	dos2unix -o stream.part3.new 
	unix2dos -o stream.part3.mp3.base64
	cat stream.part3.mp3.base64 >> stream.part3.new

	# save voicemail in tmp folder in case of trouble
	# TMPMP3=$(mktemp -u /tmp/msg_XXXXXXXX.mp3)
	# cp "stream.part3.mp3" "$TMPMP3"

	RESULT=`wav_transcribe.sh "./stream.part3.wav"`

	FILTERED=`echo "$RESULT" | jq -r '.transcription'`
	 	   
	# generate first part of mail body, converting it to LF only
	mv stream.part stream.new
	cat stream.part1 >> stream.new
	sed '$d' < stream.part2 >> stream.new

	# beginning of transcription section
	echo "" >> stream.new
	echo "--- Transcription result ---" >> stream.new

	# append result of transcription
	if [ -z "$FILTERED" ]
	then
	  echo "(StratusTalk was unable to recognize any speech in audio data.)" >> stream.new
	else
	  echo "$FILTERED" >> stream.new
	fi

	# end of message body
	tail -1 stream.part2 >> stream.new

	# add converted attachment  
	cat stream.part3.new >> stream.new

	# append end of mail body, converting it to LF only
	echo "" >> stream.tmp
	echo "" >> stream.tmp
	cat stream.part4 >> stream.tmp
	dos2unix -o stream.tmp
	cat stream.tmp >> stream.new
 
fi
 
# send the mail thru sendmail
cat stream.new | sendmail -t
 
# go back to original directory
popd
 
# remove all temporary files and temporary directory
rm -Rf $TMPDIR
