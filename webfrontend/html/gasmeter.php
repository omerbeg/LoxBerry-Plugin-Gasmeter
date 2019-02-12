<?php
#TODO fix this PATH to DB
$db = new SQLite3('gasmeter_database.sqlite3');
$row = $db->query('SELECT sum(counter) as counter FROM gasmeter_t');

# TODO read this startdata from config
$gasmeter_startdata = 1303800;

while ($data = $row->fetchArray()) {
	$gasmeter_data=($data[0]*10)+$gasmeter_startdata;
}
$gasmeter_data=substr($gasmeter_data,0,-3).".".substr($gasmeter_data,-3,3);

print "<br/>Gasmeter: " . $gasmeter_data . " m3";

?>

