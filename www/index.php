<!DOCTYPE html>
<html>
	<head>
		<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
		<script>
			function displayDate()
			{
				document.getElementById("demo").innerHTML=Date();
			}

			var txt="";
			function message()
			{
				try
				{
					adddlert("Welcome guest!");
				}
				catch(err)
				{
					txt="There was a man made error on this page.\n\n";
					txt+="Error description: " + err.message + "\n\n";
					txt+="Click OK to continue.\n\n";
					alert(txt);
				}
			}

                </script>
		<script type="text/javascript">
			$(document).ready(function(){
//				$("button").click(function(){
					$("#div1").fadeIn();
					$("#div2").fadeIn("1000");
					$("#div3").fadeIn(3000);
					$("#div4").fadeIn(5000);
					$("#div5").fadeIn(7000);
					$("#div6").fadeIn(9000);
					$("#div7").fadeIn(11000);
//				});
			});
		</script>

	</head>

        <body>
                <h1>Welcome to hallon1</h1>

                <?php
                        ini_set('display_errors', 'On');
                        error_reporting(E_ALL | E_STRICT);
                        set_time_limit(1000);
                        $time = microtime();
                        $time = explode(' ', $time);
                        $time = $time[1] + $time[0];
                        $start = $time;

                        echo "Innetemp (10.728892010800) = ";
                        $output = null;
                        exec('cat /mnt/1wire/10.728892010800/temperature', $output);
                        foreach ($output as $value) {
                                echo ("$value<br />");
                        }
                        echo "";
                        echo "Utetemp (10.C58384010800) = ";
                        $output = null;
                        exec('cat /mnt/1wire/10.C58384010800/temperature', $output);
                        foreach ($output as $value) {
                                echo ("$value<br />");
                        }
                        echo "";
                        echo "Guest room temp (28.1B6170020000) = ";
                        $output = null;
                        exec('cat /mnt/1wire/28.1B6170020000/temperature', $output);
                        foreach ($output as $value) {
                                echo ("$value<br />");
                        }
                ?>

		<p id="demo">This is Mathias Hallon sida!</p>
		<button type="button" onclick="displayDate()">Display Date</button>
		<br>

		<iframe src="http://free.timeanddate.com/clock/i3wmih3b/n239/szw210/szh210/hoc000/hbw2/hfceee/cf100/hncccc/fdi76/mqc000/mql10/mqw4/mqd98/mhc000/mhl10/mhw4/mhd98/mmc000/mml10/mmw1/mmd98" frameborder="0" width="212" height="212"></iframe>

		<br>

		<input type="button" value="View message" onclick="message()" />
		<br>

		<br>


		<table border="0">
			<tr>
				<td>
					<div id="div1" style="width:80px;height:80px;display:none;background-color:#FF0000;"></div>
				</td>
				<td>
					<div id="div2" style="width:80px;height:80px;display:none;background-color:#FF7F00;"></div>
				</td>
				<td>
					<div id="div3" style="width:80px;height:80px;display:none;background-color:#FFFF00;"></div>
				</td>
				<td>
					<div id="div4" style="width:80px;height:80px;display:none;background-color:#00FF00;"></div>
				</td>
				<td>
					<div id="div5" style="width:80px;height:80px;display:none;background-color:#0000FF;"></div>
				</td>
				<td>
					<div id="div6" style="width:80px;height:80px;display:none;background-color:#6600FF;"></div>
				</td>
				<td>
					<div id="div7" style="width:80px;height:80px;display:none;background-color:#8B00FF;"></div>
				</td>
			</tr>
		</table>

		<br>
		<br>
		<a href="/temperature.html">Go to Mathias temperatursida</a> 
        </body>

</html>
