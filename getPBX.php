#!/usr/bin/php
<?php
	$handle = popen('/usr/local/bin/peers','r');
	$peers = fread($handle, 10000);
	pclose($handle);

	$handle = popen('/usr/bin/uptime','r');
	$uptime = fread($handle, 10000);
	pclose($handle);

	$handle = popen('/sbin/ifconfig','r');
	$ifconfig = fread($handle, 10000);
	pclose($handle);

	$handle = popen('/bin/hostname','r');
	$hostname = fread($handle, 10000);
	pclose($handle);

	$handle = popen('/bin/netstat -rn','r');
	$routes = fread($handle, 10000);
	pclose($handle);

	$handle = popen('/usr/local/bin/sipalerts','r');
	$alerts = fread($handle, 10000);
	pclose($handle);

	$ret = array(
		'hostname' => $hostname,
		'peers' => $peers,
		'uptime' => $uptime,
		'routes' => $routes,
		'alerts' => $alerts,
		'ifconfig' => $ifconfig);
	echo json_encode($ret);
?>
