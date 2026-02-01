@echo off
::This file was created automatically by CrossIDE to compile with C51.
C:
cd "\Source\MAX10_8052\Boot\"
"C:\Source\call51\Bin\c51.exe" --use-stdout --code-loc 0xf000 "C:\Source\MAX10_8052\Boot\CV_Boot_UFM.c"
if not exist hex2mif.exe goto done
if exist CV_Boot_UFM.ihx hex2mif CV_Boot_UFM.ihx
if exist CV_Boot_UFM.hex hex2mif CV_Boot_UFM.hex
:done
echo done
echo Crosside_Action Set_Hex_File C:\Source\MAX10_8052\Boot\CV_Boot_UFM.hex
