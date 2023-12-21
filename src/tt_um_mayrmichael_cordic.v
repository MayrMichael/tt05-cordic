`default_nettype none
`include "cordic_iterative.v"

module tt_um_mayrmichael_cordic (
    /* verilator lint_off UNUSEDSIGNAL */
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    /* verilator lint_on UNUSEDSIGNAL */
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    wire [7:0] x, y;

    /* verilator lint_off UNUSEDSIGNAL */
    wire [7:0] z_o, y_o;
    /* verilator lint_on UNUSEDSIGNAL */

    wire data_arrived, data_finished;
    wire [6:0] unused_i_wire;

    assign x = 8'b01001011; 
    assign y = 8'b00000000;

    assign uio_oe = 8'b00000001;
    assign uio_out[7:1] = 7'b0000000;
    assign uio_out[0] = data_finished;
    assign data_arrived = uio_in[1];


    cordic_iterative CORDIC_ITERATIVE_INST
    (.clk_i(clk),
     .rst_i(rst_n),
     .x_i(x),
     .y_i(y),
     .z_i(ui_in),
     .data_in_valid_strobe_i(data_arrived),
     .x_o(uo_out),
     .y_o(z_o),
     .z_o(y_o),
     .data_out_valid_strobe_o(data_finished)
     );
    

endmodule
