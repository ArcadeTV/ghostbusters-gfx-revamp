<?php
// read FULL file:
$rom_filepath = "../assets/gfx/ig4000_tiledata.bin";
$handle   = fopen($rom_filepath, "rb");
$filesize = filesize($rom_filepath);
$contents = fread($handle, $filesize);
fclose($handle);

$a = str_split($contents,10*32);

$tiledata_0 = '';
for($i=0; $i<22; $i+=3){
    $tiledata_0 .= $a[$i];
}
file_put_contents("tiledata_0.bin", $tiledata_0);

$tiledata_1 = '';
for($i=1; $i<22; $i+=3){
    $tiledata_1 .= $a[$i];
}
file_put_contents("tiledata_1.bin", $tiledata_1);

$tiledata_2 = '';
for($i=2; $i<22; $i+=3){
    $tiledata_2 .= $a[$i];
}
file_put_contents("tiledata_2.bin", $tiledata_2);
?>