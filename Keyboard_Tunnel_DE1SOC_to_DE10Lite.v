module Keyboard_Tunnel_DE1SOC_to_DE10Lite(
    input wire PS2_CLK,    
    input wire PS2_DATA,  
    output wire PS2_CLK_O,   
    output wire PS2_DATA_O,  
    output [3:0] LEDR
);

  assign PS2_CLK_O  = 1'bz;
  assign PS2_DATA_O = 1'bz;

  assign LEDR[0] = PS2_CLK;
  assign LEDR[1] = PS2_CLK;
  assign LEDR[2] = PS2_DATA;
  assign LEDR[3] = PS2_DATA;

endmodule