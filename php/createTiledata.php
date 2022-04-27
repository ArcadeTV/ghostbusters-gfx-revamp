<?php
/*
=================================================================================================== 
# Create Tiledata:
---------------------------------
Needs the following from Aseprite
1.0 Export Spritesheet
1.1 The Image as PNG
1.2 JSON Data
2.0 Palette in hex file format
===================================================================================================
*/

/* ### D E F I N I T I O N S #################################################################### */

define("BYTE",              2);
define("WORD",              4);
define("LONGWORD",          8);
define("TILESIZE",          8);
define("DS",                DIRECTORY_SEPARATOR);


/* ### S E T U P ################################################################################ */

$palFile    = "palette.hex";    // Aseprite -> Palette -> save, filetype hex
$jsonFile   = "tileset.json";   // Aseprite -> export spritesheet, filetype json, with slices
$imgFile    = "tileset.png";    // Aseprite -> export spritesheet, filetype png
$binFile    = "tiledata.bin";   // Filename for the created data
$mode       = "plane";          // mode: "sprite" is up->down, "plane" is left->right

/* ### P R O G R A M ############################################################################ */

if(!file_exists($palFile) || !file_exists($jsonFile) || !file_exists($imgFile)){
    die("Palette File not found.");
}

// Parse hex palette to array:
$palette = array_filter(file($palFile), fn($value) => !is_null($value) && $value !== '');
$palette = array_map(fn($value) => strtoupper($value) & trim($value), $palette);
var_dump($palette);

// parse Aseprite image and slices data:
$json = file_get_contents($jsonFile);
$ase  = json_decode($json);

// get image dimensions
$imgH          = $ase->meta->size->h;
$imgW          = $ase->meta->size->w;
$tilesInImageH = $imgH/TILESIZE;
$tilesInImageW = $imgW/TILESIZE;
$tilesInImage  = $tilesInImageW * $tilesInImageH;

// create an image ressource:
$image = imagecreatefrompng($imgFile);

// create a virtual canvas for placing and re-ordering tiles:
$canvas = imagecreatetruecolor($imgW, $imgH);

$nybblesArray = [];
$slices = $ase->meta->slices;
$tileID = 0;

// do for all slices specified in json data:
for($s=0; $s<count($slices); $s++){
    $sliceX        = $slices[$s]->keys[0]->bounds->x;
    $sliceY        = $slices[$s]->keys[0]->bounds->y;
    $sliceH        = $slices[$s]->keys[0]->bounds->h;
    $sliceW        = $slices[$s]->keys[0]->bounds->w;
    $tilesInSliceH = ($sliceH/TILESIZE);
    $tilesInSliceW = ($sliceW/TILESIZE);
    $tilesInSlice  = $tilesInSliceH * $tilesInSliceW;


    if($mode=="sprite"){

        // SPRITE MODE: up->down then left->right
        for($tX=0; $tX < $tilesInSliceW; $tX++){
            for($tY=0; $tY < $tilesInSliceH; $tY++) {
    
                $tileXstart = ($tX * TILESIZE) + $sliceX;
                $tileYstart = ($tY * TILESIZE) + $sliceY;
                $canvasX    = ($tileID % $tilesInImageW);
                $canvasY    = ($tileID - $canvasX) / $tilesInImageW;
    
                // copy chunks of TILESIZE to canvas:
                imagecopymerge($canvas, $image, $canvasX * TILESIZE, $canvasY * TILESIZE, $tileXstart, $tileYstart, TILESIZE, TILESIZE, 100);
    
                $tileID++;
            }
        }

    }else{

        // PLANE MODE: left->right then up->down
        for($tY=0; $tY < $tilesInSliceH; $tY++) {
            for($tX=0; $tX < $tilesInSliceW; $tX++){
    
                $tileXstart = ($tX * TILESIZE) + $sliceX;
                $tileYstart = ($tY * TILESIZE) + $sliceY;
                $canvasX    = ($tileID % $tilesInImageW);
                $canvasY    = ($tileID - $canvasX) / $tilesInImageW;
    
                // copy chunks of TILESIZE to canvas:
                imagecopymerge($canvas, $image, $canvasX * TILESIZE, $canvasY * TILESIZE, $tileXstart, $tileYstart, TILESIZE, TILESIZE, 100);
    
                $tileID++;
            }
        }

    } // endif mode
} // endfor count slices

// save the number of tiles used for later
$tilesTotal = $tileID+1;

// write the resulting tilesheet to a PNG file:
imagepng($canvas, 'canvas.png');

// Sample the created image and create binary data:
// tile by tile
for($tY=0; $tY < $tilesInImageH; $tY++) {
    for($tX=0; $tX < $tilesInImageW; $tX++){
        
        $tileXstart = $tX * TILESIZE;
        $tileYstart = $tY * TILESIZE;
        
        // pixel by pixel
        for($y=$tileYstart; $y < $tileYstart+TILESIZE; $y++) {
            for($x=$tileXstart; $x < $tileXstart+TILESIZE; $x++){
                $rgb = imagecolorat($canvas, $x, $y);
                $colors = imagecolorsforindex($canvas, $rgb);
    
                $r = $colors['red'];
                $g = $colors['green'];
                $b = $colors['blue'];
    
                $red   = min(255, $r);
                $green = min(255, $g);
                $blue  = min(255, $b);
    
                $luma  = floor((54.213 * $red) + (182.376 * $green) + (18.411 * $blue)) & 1;
                $dec   = (($luma ^ 1) << 15) | (($red & 1) << 14) | (($green & 1) << 13) | (($blue & 1) << 12) | (($red & 0x1E) << 7) | (($green & 0x1E) << 3) | ($blue >> 1);
                $hex   = dec2hex($red, 2) . dec2hex($green, 2) . dec2hex($blue, 2);
    
                $colorID = array_search($hex, $palette);
                $nybblesArray[] = dec2hex($colorID, 1);
            }
        }
        
        // only process the number of tiles needed:
        $tileID--;
        if($tileID == 0){
            break 2;
        }
        
    }
}

imagedestroy($canvas);
imagedestroy($image);

    // Convert the hex array to binary:
    $binary = "";
    $bytesArray = str_split(implode("", $nybblesArray), 2);
    for($i=0; $i < count($bytesArray); $i++){
        $binary .= pack('H*', $bytesArray[$i]);
    }

    // save the binary file:
    file_put_contents($binFile, $binary);

    // say goodbye:
    echo 'Done.';

// -the end-


/* ### F U N C T I O N S ######################################################################################## */

function dec2hex($dec, $digits = 2){
    return strtoupper( str_pad(  dechex( bindec( base_convert($dec, 10, 2) ) )  , $digits, '0', STR_PAD_LEFT) );
}

?>