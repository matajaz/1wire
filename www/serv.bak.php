<?php
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

function mysql2json($mysql_result,$name){
	$json="{\n\"$name\": [\n";
	$field_names = array();
	$fields = mysql_num_fields($mysql_result);
	for($x=0;$x<$fields;$x++){
		$field_name = mysql_fetch_field($mysql_result, $x);
		if($field_name){
			$field_names[$x]=$field_name->name;
		}
	}
	$rows = mysql_num_rows($mysql_result);
	for($x=0;$x<$rows;$x++){
		$row = mysql_fetch_array($mysql_result);
		$json.="{\n";
		for($y=0;$y<count($field_names);$y++) {
			$json.="\"$field_names[$y]\" :	\"$row[$y]\"";
			if($y==count($field_names)-1){
				$json.="\n";
			}
			else{
				$json.=",\n";
			}
		}
		if($x==$rows-1){
			$json.="\n}\n";
		}
		else{
			$json.="\n},\n";
		}
	}
	$json.="]\n};";
	return($json);
}
// ======================================================================================================
// START

$logging = write_log(PHP_EOL . PHP_EOL . "=============================================================================================================");
$logging = write_log("server.php startar: $start");
//var_dump($logging);
//exit;

	$result = connect("show tables");
	$type ="ERROR: Wrong method";
	//	$result = connect("select * from animals");
//	if (isset($_GET['json']) or isset($_POST['json'])){
		if (isset($_GET['json'])){
			$type = "GET";
		}elseif (isset($_POST['json'])){
			$type = "POST";
		}
//		echo "type=$type<br>";

//		echo $_REQUEST["query1"];
//		$phpobj1= json_decode($_GET['json']);
/*		echo $phpobj1->name;
		echo " ";
		echo $phpobj1->myArr[0];
		echo " ";
		echo $phpobj1->myArr[1];
*/
/*
		$phpobj2= json_decode($_GET['json'], true);

		echo $phpobj2['name'];
		echo " ";
		echo $phpobj2['myArr'][0];
		echo " ";
		echo $phpobj2['myArr'][1];
		echo " ";
*/
//		$phpassoc= json_decode($_GET['json'], true);
//		$phpassoc= json_decode($_POST['json'], true);
//		$jsonstr = json_encode($phpassoc);
//		$jsonstr = json_encode($result);
//		echo $jsonstr;
		if ($type == "POST"){
			$queryobj = json_decode($_POST['json']);
		}
		elseif($type ="GET"){
			$queryobj = json_decode($_GET['json']);
		}else{
			echo "Access method is not valid!";
			exit;
		}

//		$queriesstring = $queryobj->queries;
		$queriesstring = $queryobj;
//		echo ("querystring=" . $queriesstring);
//		$queriesarray = preg_split("/QUERY:/",$queriesstring);
//		$storlek=count($queriesarray);
//		$logging = write_log("Arraystorlek=$storlek");
//		for ( $counter = 0; $counter < count($queriesarray); $counter ++) {
			$q1time = microtime(true);
//			$query = $queriesarray[$counter];
			$query = $queriesstring;
//			$logging = write_log("QUERY: start=$start, counter=$counter, $query");
			$sqlresult = mysql_query($query) or die("Query failed with error: ".mysql_error() . " Query = " . $query . ", Query no: " . $counter);
			$q2time = microtime(true);
			$rows = mysql_num_rows($sqlresult) or die(mysql_error());
			$logging = write_log("Query result received, rows=$rows");
			While ($raw = mysql_fetch_array ($sqlresult,MYSQL_ASSOC)){	// This is really slow

                                $time = strtotime($raw['TimeStamp']);
				$point = array($time,floatval($raw['Temperature']));
				$json[] = $point;

			} // end while
			$jsonstr = json_encode($json);
			echo $jsonstr;


//			if ($counter < count($queriesarray) -1){
//				echo "serie:";
//			}
			$p2time = microtime(true);
//			$ptime[$counter] = round(($p2time - $q2time), 4);
//			$qtime = round(($etime - $stime), 4);
//			$logging = write_log("Query result printed, etime=$p2time, qtime=$qtime, ptime=$ptime" . PHP_EOL);
//		} // end foor loop

	$time = microtime();
	$time = explode(' ', $time);
	$time = $time[1] + $time[0];
	$finish = $time;
	$total_time = round(($finish - $start), 4);
	$logging = write_log(PHP_EOL . "Page generated in $total_time seconds" . PHP_EOL);
//var_dump($query_time);


?>
