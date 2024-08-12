#!/usr/bin/php
<?php
        $handle = popen('/usr/local/bin/pings','r');
        $var = fread($handle, 10000);
        preg_match_all('!\d+!', $var, $pings);
        pclose($handle);

        $ret = array(
                'pings' => $pings);
        echo json_encode($ret);

        print_r($pings);
?>


