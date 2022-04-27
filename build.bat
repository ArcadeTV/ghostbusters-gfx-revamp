@echo off
CLS

set VERSION=%date:/=.%
set "EXT=.md"
set "INFILE=Ghostbusters (USA, Europe)%EXT%"
set "OUTFILE=Ghostbusters (USA, Europe)[GFX Revamp, ArcadeTV]%EXT%"
set "PATCHFILENAME=Ghostbusters (USA, Europe)[GFX Revamp, ArcadeTV, WIPv%VERSION%]"
set "ZIPFILENAME=Ghostbusters-GFX-Revamp_wip(%VERSION%).zip"

REM -----------------------------------------------------------------------------------------------
REM Check Source ROM

if %1==force goto skipcheck

IF EXIST ".\roms\%INFILE%" (
	.\tools\win\checkhash.exe ".\roms\%INFILE%" AD18B994E0A38124AB3565709011803AB4ACF1E23592BB58473DFB88B999A49F > NUL && echo Source ROM passed file check. || echo Incorrect Source Rom. Aborting. && exit /b
) ELSE (
	echo Source ROM "%INFILE%" not found. Aborting.
  exit /b
)

:skipcheck

REM -----------------------------------------------------------------------------------------------
REM delete any old versions

if exist ".\roms\%OUTFILE%" (
  DEL ".\roms\%OUTFILE%"
  echo Deleted old ROM file>.\tmp\build.log
)
if exist .\roms\*.zip (
  DEL .\roms\*.zip
  echo Deleted old ZIP file>.\tmp\build.log
)
if exist .\roms\*.bps (
  DEL .\roms\*.bps
  echo Deleted old BPS file>.\tmp\build.log
)

REM -----------------------------------------------------------------------------------------------
REM create version file

echo     dc.b " - %VERSION% - ">.\includes\version.asm
echo Set version to %VERSION%>>.\tmp\build.log



REM -----------------------------------------------------------------------------------------------
REM copy unmodified ROM and apply padding

REM 8MBIT=1MBYTE=(8*128*1024)BYTES
copy ".\roms\%INFILE%" ".\roms\padded_rom.bin">>.\tmp\build.log && .\tools\win\pad.exe .\roms\padded_rom.bin 1048576 255>>.\tmp\build.log



REM -----------------------------------------------------------------------------------------------
REM patch the ROM

echo Building...
.\tools\win\vasmm68k_mot_win32.exe .\patch.asm -quiet -chklabels -nocase -rangewarnings -Dvasm=1 -L tmp\Listing.txt -DBuildGEN=1 -Fbin -Fsrec -o tmp\srecfile.txt
.\tools\win\srecpatch.exe ".\roms\padded_rom.bin" ".\roms\%OUTFILE%"<.\tmp\srecfile.txt>>.\tmp\build.log


REM -----------------------------------------------------------------------------------------------
REM remove tmp file

if exist ".\roms\padded_rom.bin" (
  DEL ".\roms\padded_rom.bin" 
  echo Deleted temp padded ROM file>>.\tmp\build.log
)


REM -----------------------------------------------------------------------------------------------
REM fix the checksum in the header

.\tools\win\fixheader.exe ".\roms\%OUTFILE%"
echo fixed header checksum>>.\tmp\build.log



REM -----------------------------------------------------------------------------------------------
REM create bps patchfile

.\tools\win\flips.exe --create ".\roms\%INFILE%" ".\roms\%OUTFILE%" ".\roms\%PATCHFILENAME%.bps"


REM -----------------------------------------------------------------------------------------------
REM create zip from the bps file

cd /D roms
..\tools\win\7z.exe a %ZIPFILENAME% *.bps>>..\tmp\build.log
cd /D ..


echo done!