<?php
// simple counter
// the JS part is from Goatcounter

$ipaddress = $_SERVER['REMOTE_ADDR'];
$timestamp = date('Y/m/d H:i:s');
$referrer = $_GET['r'];
$page  = $_GET['p'];
$dimensions = $_GET['s'];
$bot = $_GET['b'];
$browser = $_SERVER['HTTP_USER_AGENT'];

$msg = md5($ipaddress) . "\t$timestamp\t$page\t$referrer\t$browser\t$dimensions\t$bot\n";

$result = file_put_contents(getcwd(). "/counter.txt",$msg, FILE_APPEND | LOCK_EX) or print_r(error_get_last());;
?>
