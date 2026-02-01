@echo off
::This file was created automatically by CrossIDE to compile with C51.
C:
cd "\Source\MAX10_8052_FD_ADC\Test\Code\"
"C:\Source\call51\Bin\c51.exe" --use-stdout --code-loc 0x0000 "C:\Source\MAX10_8052_FD_ADC\Test\Code\ADC_Test.c"
if not exist hex2mif.exe goto done
if exist ADC_Test.ihx hex2mif ADC_Test.ihx
if exist ADC_Test.hex hex2mif ADC_Test.hex
:done
echo done
echo Crosside_Action Set_Hex_File C:\Source\MAX10_8052_FD_ADC\Test\Code\ADC_Test.hex
