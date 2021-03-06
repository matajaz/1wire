<?php
//	header('content-type: application/json; charset=utf-8');
	header("access-control-allow-origin: *");

	error_reporting(E_ALL);
	ini_set('display_errors',1);
	ob_start();
	//error_reporting(8183);
	
	set_time_limit(1000);
	$time = microtime();
	$time = explode(' ', $time);
	$time = $time[1] + $time[0];
	$start = $time;

function write_log($message) {
/**
  * write_log($message)
  * 
  * Writes the values of certain variables along with a message in a log file.
  *
  * Parameters:
  *  $message:   Message to be logged
  *
  * Returns array:
  *  $result[status]:   True on success, false on failure
  *  $result[message]:  Error message
  */
 
	$logfile = "php_logfile.txt";
	$status = false;
	// Determine log file
	if($logfile == '') {
	// checking if the constant for the log file is defined
		if (defined(DEFAULT_LOG)) {
			$logfile = DEFAULT_LOG;
		}
		// the constant is not defined and there is no log file given as input
		else {
			error_log('No log file defined!',0);
			return array($status => false, $message => 'No log file defined!');
		}
	}
	// Get time of request
	if( ($time = $_SERVER['REQUEST_TIME']) == '') {
		$time = time();
	}
	
	// Get IP address
	if( ($remote_addr = $_SERVER['REMOTE_ADDR']) == '') {
		$remote_addr = "REMOTE_ADDR_UNKNOWN";
	}
	
	// Get requested script
	if( ($request_uri = $_SERVER['REQUEST_URI']) == '') {
		$request_uri = "REQUEST_URI_UNKNOWN";
	}
	
	// Format the date and time
	date_default_timezone_set('Europe/Stockholm');
//	$date = date("Y-m-d H:i:s", $time);

	$t = microtime(true);
	$micro = sprintf("%06d",($t - floor($t)) * 1000000);
	$d = new DateTime( date('Y-m-d H:i:s.' . $micro, $t) );

	$date = $d->format("Y-m-d H:i:s.u");

	// Append to the log file
	if($fd = @fopen($logfile, 'ab')) {
//		$result = fputcsv($fd, array($date, $remote_addr, $request_uri, $message));
		$result = fputcsv($fd, array($date, $remote_addr, $message));
	fclose($fd);
 
	if($result > 0)
		return array($status => true);  
	else
		return array($status => false, $message => 'Unable to write to '.$logfile.'!');
	}
	else {
		return array($status => false, $message => 'Unable to open log '.$logfile.'!');
	}
}

function connect($sql)
{
	$host		= get_cfg_var('mysql.host'); 
    $username	= get_cfg_var('mysql.user'); 
    $pwd		= get_cfg_var('mysql.pass');
    $dbname		= get_cfg_var('mysql.dbname');
	if (!($conn=mysql_connect($host, $username, $pwd)))  {
		printf("error connecting to DB");
		exit();
	}
	$db=mysql_select_db($dbname,$conn);
	$result = mysql_query($sql);
	if ($result){
		return $result;
	}else{
		$error = mysql_error();
		echo "Can't complete query because $error";
		die();   
	}
}

function stripslashes_array(&$arr) {
	echo "arr=$arr<br>";
	foreach ($arr as $k => &$v) {
		$nk = stripslashes($k);
		if ($nk != $k) {
			$arr[$nk] = &$v;
			unset($arr[$k]);
		}
		if (is_array($v)) {
			stripslashes_array($v);
		} else {
			$arr[$nk] = stripslashes($v);
		}
	}
}

function encode_single_query_result($queryobj)
{
	$query = mysql_real_escape_string(trim($queryobj));
//	echo "Single query: $query<br>";
//	echo "<br><br>";
	$query = stripslashes($query);		// pga jsonstr fuckar upp det
	$logging = write_log("Single Query: '$query'");

	$matches = array();
	$column = array();
	if (preg_match("/SELECT (.+) FROM/i", $query,$matches)) {
		$columnstr = $matches[1];
		$column = explode(",", $columnstr);
		$i = 0;
		foreach ($column as $col){
			$logging = write_log("Col $i: $column[$i]");
			$i++;
		}
	}
	$result = array();
	$sqlresult = mysql_query($query) or die("Single query failed with error: ".mysql_error() . " Query = " . $query . "<br><br>");
	
	While ($raw = mysql_fetch_array ($sqlresult,MYSQL_ASSOC)){	// This is really slow
/*		if (preg_match("/as Day/i", $query)) {
			$time = strtotime($raw['Day']) * 1000;	// javascript uses milli seconds
		} elseif (preg_match("/as Week/i", $query)) {
			$time = strtotime($raw['Week']) * 1000;	// javascript uses milli seconds
		} elseif (preg_match("/as Month/i", $query)) {
			$time = strtotime($raw['Month']) * 1000;	// javascript uses milli seconds
		}else {
			$time = strtotime($raw['TimeStamp']) * 1000;	// javascript uses milli seconds
		}
*/
		$time = strtotime($raw["$column[0]"]) * 1000;	// javascript uses milli seconds
		if (preg_match("/MAX/i", $query) and preg_match("/MIN\(/i", $query)) {
			$point = array($time,floatval($raw["$column[1]"]),floatval($raw["$column[2]"]));
		}else{
			$point = array($time,floatval($raw["$column[1]"]));
		}
		$result[] = $point;
	} // end while
	$jsonstr = json_encode($result);
	return $jsonstr;
}

function encode_multiple_query_results($queryobj)
{
//	echo "Single query: $query<br>";
//	echo "<br><br>";
//	var $query = array();
//	$query = stripslashes_array($queryobj);		// pga jsonstr fuckar upp det

	$result = array();
	for ( $counter = 0; $counter < count($queryobj); $counter ++) {
		$q1time = microtime(true);
		$query = mysql_real_escape_string(trim($queryobj[$counter]));
		$logging = write_log("Multiple Query $counter: '$query'");

		$matches = array();
		$column = array();
		if (preg_match("/SELECT (.+) FROM/i", $query,$matches)) {
			$columnstr = $matches[1];
			$column = explode(",", $columnstr);
			$i = 0;
			foreach ($column as $col){
				$logging = write_log("Col $i: $column[$i]");
				$i++;
			}
		}
		$sqlresult = mysql_query($query) or die("Query failed with error: ".mysql_error() . " Query = " . $query . ", Query no: " . $counter);
		$q2time = microtime(true);
		$rows = mysql_num_rows($sqlresult) or die(mysql_error());
		$logging = write_log("Query result received, rows=$rows");
		While ($raw = mysql_fetch_array ($sqlresult,MYSQL_ASSOC)){	// This is really slow
//			$time = strtotime($raw['TimeStamp']) * 1000;	// javascript uses milli seconds
			$time = strtotime($raw["$column[0]"]) * 1000;	// javascript uses milli seconds
			if (preg_match("/MAX/i", $query) and preg_match("/MIN\(/i", $query)) {
				$point = array($time,floatval($raw["$column[1]"]),floatval($raw["$column[2]"]));
			}else {
				$point = array($time,floatval($raw["$column[1]"]));
			}

			$result[$counter][] = $point;
		} // end while
	} // end for
	$jsonstr = json_encode($result);
	return $jsonstr;
}
function is_valid_callback($subject)
{
	$identifier_syntax = '/^[$_\p{L}][$_\p{L}\p{Mn}\p{Mc}\p{Nd}\p{Pc}\x{200C}\x{200D}]*+$/u';

	$reserved_words = array('break', 'do', 'instanceof', 'typeof', 'case',
		'else', 'new', 'var', 'catch', 'finally', 'return', 'void', 'continue', 
		'for', 'switch', 'while', 'debugger', 'function', 'this', 'with', 
		'default', 'if', 'throw', 'delete', 'in', 'try', 'class', 'enum', 
		'extends', 'super', 'const', 'export', 'import', 'implements', 'let', 
		'private', 'public', 'yield', 'interface', 'package', 'protected', 
		'static', 'null', 'true', 'false');

	return preg_match($identifier_syntax, $subject)
		&& ! in_array(mb_strtolower($subject, 'UTF-8'), $reserved_words);
}

// ======================================================================================================
// START

$logging = write_log(PHP_EOL . PHP_EOL . "=============================================================================================================");
$logging = write_log("server.php startar: $start");
//var_dump($logging);
//exit;

	$result = connect("show tables");
	$type ="ERROR: Wrong method";
	if( isset($_GET['callback'])){
		$type = "GET";
		$callback = $_GET["callback"];
	}
	if (isset($_GET['json'])){
		$type = "GET";
	}elseif (isset($_POST['json'])){
		$type = "POST";
	}
	if ($type == "POST"){
		$queryobj = json_decode($_POST['json']);
	}
	elseif($type ="GET"){
		$queryobj = json_decode($_GET['json']);
	}else{
		echo "Access method is not valid!";
		exit;
	}

//echo ("callback=".$callback."<br>");
//echo ("obj=".$queryobj."<br>");
	if (count($queryobj) > 1){
		$jsonResponse = encode_multiple_query_results($queryobj);
	}else{
		$jsonResponse = encode_single_query_result($queryobj);
	}
	if (isset($callback)){
		# JSONP if valid callback
		if(is_valid_callback($callback)){
			echo $callback . "(" . $jsonResponse . ")";
		}else{
			header('status: 400 Bad Request, hehe', true, 400);
		}
	}else{
		echo $jsonResponse;
	}

	$time = microtime();
	$time = explode(' ', $time);
	$time = $time[1] + $time[0];
	$finish = $time;
	$total_time = round(($finish - $start), 4);
	$logging = write_log(PHP_EOL . "Page generated in $total_time seconds" . PHP_EOL);
//var_dump($query_time);


?>
