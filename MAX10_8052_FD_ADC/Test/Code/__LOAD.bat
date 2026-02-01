@echo off
::This file was created automatically by CrossIDE to load a hex file using Quartus_stp.
"C:\intelFPGA_lite\23.1std\quartus\bin64\quartus_stp.exe" -t "C:\Source\crosside\Load_Script.tcl" "C:\Source\MAX10_8052_FD_ADC\Test\Code\Accelerometer.HEX" | find /v "Warning (113007)"
