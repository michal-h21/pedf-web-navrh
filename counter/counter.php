<?php
/* var_export($_GET); */

$ipaddress = $_SERVER['REMOTE_ADDR'];
$timestamp = date('Y/m/d h:i:s');
$referrer = $_GET['r'];
$page  = $_GET['p'];
$dimensions = $_GET['s'];
$bot = $_GET['b'];
$browser = $_SERVER['HTTP_USER_AGENT'];

$msg = md5($ipaddress) . "\t$timestamp\t$page\t$referrer\t$browser\t$dimensions\t$bot\n";

echo($msg);
$result = file_put_contents(getcwd(). "/counter.txt",$msg, FILE_APPEND | LOCK_EX) or print_r(error_get_last());;
/* if($result===false){ */
/* echo "něco je špatně<br />"; */
/* }else{ */
/* echo "v pohodě?"; */
/* } */
/* echo("what?"); */
?>
