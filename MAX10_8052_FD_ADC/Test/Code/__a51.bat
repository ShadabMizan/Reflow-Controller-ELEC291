@echo off
C:
cd "\Source\MAX10_8052_FD_ADC\Test\Code\"
"C:\Source\call51\bin\a51.exe" -l "C:\Source\MAX10_8052_FD_ADC\Test\Code\Accelerometer.asm"
echo Crosside_Action Set_Hex_File C:\Source\MAX10_8052_FD_ADC\Test\Code\Accelerometer.HEX
