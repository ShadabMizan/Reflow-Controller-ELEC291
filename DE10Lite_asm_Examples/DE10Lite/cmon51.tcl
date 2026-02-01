# Script mostly from:
# http://quartushelp.altera.com/current/mergedProjects/tafs/tafs/tcl_pkg_jtag_ver_1.0_cmd_get_device_names.htm
#
# List all available programming hardwares, and select the USBBlaster.
# (Note: this script assumes only one USBBlaster connected.)
#puts "JTAG chains:"

if { [catch get_hardware_names] } {
	post_message -type error "USB-Blaster hardware not found."
	exit
}

foreach hardware_name [get_hardware_names] {
	post_message -type info "Hardware name: $hardware_name"
	if { [string match "USB-Blaster*" $hardware_name] } {
		set usbblaster_name $hardware_name
	}
	if { [string match "DE-SoC*" $hardware_name] } {
		set usbblaster_name $hardware_name
	}
}

# List all devices on the chain, and select the first device on the chain.
#puts "\nDevices available on JTAG chain:"
set target_device "0"
foreach device_name [get_device_names -hardware_name $usbblaster_name] {
	post_message -type info  "Device name: $device_name"
	if { [string match "@1*" $device_name] } {
		set target_device $device_name
	}
}

# The DE1-SoC's FPGA is device number 2
if { [string match "@1: SOCVHPS*" $target_device] } {
	set target_device "0"
	foreach device_name [get_device_names -hardware_name $usbblaster_name] {
		post_message -type info  "Device name: $device_name"
		if { [string match "@2*" $device_name] } {
			set target_device $device_name
		}
	}
}

if {$target_device==0} {
	post_message -type error "Target device not found."
	exit
}

set lastbyte "0"
catch [set mem_list [get_editable_mem_instances -hardware_name $usbblaster_name -device_name $target_device]]
foreach i $mem_list {
	# puts "[lindex $i 0],[lindex $i 1],[lindex $i 2],[lindex $i 3],[lindex $i 4],[lindex $i 5]"
	if {"DEBU"==[lindex $i 5]} {
		set myindex [lindex $i 0]
		set lastbyte [expr [lindex $i 1]-1]
		post_message -type info "Valid memory found. Name: [lindex $i 5], Index: $myindex, Size: $lastbyte"
	}
}

if {$lastbyte==0} {
	post_message -type error "'DEBU' memory not found in target device."
	exit
}
#post_message -type info "Working folder [qexec "cd"]"
post_message -type info "Connecting to $usbblaster_name $target_device\n";
catch [begin_memory_edit -hardware_name $usbblaster_name -device_name $target_device]

#fconfigure stdin -translation binary -buffering none -blocking false
fconfigure stdin -blocking false

set rxcnt [read_content_from_memory -instance_index $myindex -start_address 0x2fff -word_count 1 -content_in_hex] 
set txcnt [read_content_from_memory -instance_index $myindex -start_address 0x00ff -word_count 1 -content_in_hex] 
set TIME_tx_taken 0

while {1} {
    gets stdin line
    set data_len [string length $line]
    
    if {"EXIT"==[string toupper $line]} {
	    break
    }
    if {"HANG"==[string toupper $line]} {
		post_message -type info "Disconnecting from $usbblaster_name $target_device";
		end_memory_edit
		puts "Press Enter to reconnect..."
		fconfigure stdin -blocking true
		gets stdin line
		fconfigure stdin -blocking false
		set line ""
		set data_len [string length $line]
		post_message -type info "Connecting to $usbblaster_name $target_device";
		catch [begin_memory_edit -hardware_name $usbblaster_name -device_name $target_device]
    }
    
    # Send the received line to the target memory
    set hex_string ""
    if {$data_len != "0"} then {
    	set line "$line\n"
		for {set i 0} {$i < [string length $line]} {incr i} {
			set char [string index $line $i]
			scan $char %c ascii
			set hex_string [format "%02X" $ascii]$hex_string
		}
		# Set the rest to zero
		for {set j $i} {$j < 255} {incr j} {
			set hex_string [format "%02X" 0]$hex_string
		}
		# Add the message counter
		set txcnt_old [expr 0x$txcnt]
		incr txcnt_old 1
		set txcnt [format "%02X" $txcnt_old]
		set hex_string $txcnt$hex_string
		
		#puts "$hex_string"
		
		set TIME_tx_start [clock clicks -milliseconds]
		write_content_to_memory -instance_index $myindex -start_address 0 -word_count 256 -content "$hex_string" -content_in_hex
    	set TIME_tx_taken [expr [clock clicks -milliseconds] - $TIME_tx_start]
    }

	set TIME_rx_start [clock clicks -milliseconds]
	set received [read_content_from_memory -instance_index $myindex -start_address 0x100 -word_count 0x2f00 -content_in_hex]
    set TIME_rx_taken [expr [clock clicks -milliseconds] - $TIME_rx_start]
	set rxcnt_new [string range $received 0 1]
	set mystr ""
	if {$rxcnt!=$rxcnt_new} {
    	#puts "[expr $TIME_tx_taken + $TIME_rx_taken]"
		#puts "$received"
		set rxcnt $rxcnt_new
		for {set i 1} {$i<0x2f00} {incr i} {
			set ascii_hex [string range $received [expr $i*2] [expr $i*2+1]]
			if {$ascii_hex=="00"} {
					set mystr ""
			} else {
				set mystr [format "%c" [expr 0x$ascii_hex]]$mystr
			}
		}
		puts -nonewline "$mystr"
	}
	set TIME_tx_taken 0
}
end_memory_edit
