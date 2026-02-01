@echo off
::This file was created automatically by CrossIDE to load a hex file using Quartus_stp.
"C:\Altera\16.1\quartus\bin64\quartus_stp.exe" -t "C:\Source\crosside\Load_Script.tcl" "C:\Source\MAX10_8052\Boot\Test\shared_memory_test.hex" | find /v "Warning (113007)"
