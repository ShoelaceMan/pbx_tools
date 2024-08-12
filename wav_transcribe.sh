#! /bin/bash
wav_file_path="${1}"
transcription_host="192.168.222.55"
transcription_uri="http://${transcription_host}:5001/transcribe"

# Check for arguments
if [ -z "${wav_file_path}" ]; then
	echo "No WAV file provided"
	exit 1
fi

# Check for existence of provided file
if [ ! -e "${wav_file_path}" ]; then
	echo "WAV file path at \"${wav_file_path}\" does not exist"
	exit 1
fi

# Check for connectivity to transctiption service
if ! ping -c 3 "${transcription_host}" > /dev/null; then
	echo "No connection to transcription host at \"${transcription_host}\""
	exit 1
fi

curl -X POST -F "file=@${wav_file_path}" "${transcription_uri}"
