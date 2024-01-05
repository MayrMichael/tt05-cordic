`default_nettype none


`include "sin_generator.v"
`include "top_triangle_generator.v"


module tt_um_mayrmichael_cordic (
    /* verilator lint_off UNUSEDSIGNAL */
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output reg [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    /* verilator lint_on UNUSEDSIGNAL */
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    wire [7:0] phase, amplitude;

    wire [7:0] data_sin, data_triangle, data_sawtooth, data_square_puls;

    wire data_sin_out_valid_strobe, data_triangle_out_valid_strobe, data_sawtooth_out_valid_strobe,  data_square_puls_out_valid_strobe;

    reg data_valid_strobe;

    sin_generator sin_generator_inst
    (.clk_i(clk),
     .rst_i(rst_n),
     .phase_i(ui_in),
     .new_phase_valid_strobe_i(uio_in[0]),
     .amplitude_i(ui_in),
     .new_amplitude_valid_strobe_i(uio_in[1]),
     .next_data_strobe_i(uio_in[2]),
     .data_o(data_sin),
     .data_out_valid_strobe_o(data_sin_out_valid_strobe),
     .phase_o(phase),
     .amplitude_o(amplitude)
    );

    top_triangle_generator top_triangle_generator_inst
    (.clk_i(clk),
     .rst_i(rst_n),
     .phase_i(phase),
     .amplitude_i(amplitude),					
     .next_data_strobe_i(uio_in[2]), 						
     .data_sawtooth_o(data_sawtooth),						
     .data_sawtooth_out_valid_strobe_o(data_sawtooth_out_valid_strobe),
     .data_triangle_o(data_triangle),						
     .data_triangle_out_valid_strobe_o(data_triangle_out_valid_strobe),
     .data_square_puls_o(data_square_puls),						
     .data_square_puls_out_valid_strobe_o(data_square_puls_out_valid_strobe)		
    );

    assign uio_out[7] = data_valid_strobe;

    assign uio_oe = 8'b10000000;
    assign uio_out[6:0] = 7'b0000000;

    always @(posedge clk ) begin
        if (uio_in[3] == 1'b1 && uio_in[4] == 1'b1) begin
            uo_out <= data_sin;
            data_valid_strobe <= data_sin_out_valid_strobe;
        end else if (uio_in[3] == 1'b1 && uio_in[4] == 1'b0) begin
            uo_out <= data_sawtooth;
            data_valid_strobe <= data_sawtooth_out_valid_strobe;
        end else if (uio_in[3] == 1'b0 && uio_in[4] == 1'b1) begin
            uo_out <= data_triangle;
            data_valid_strobe <= data_triangle_out_valid_strobe;
        end else begin
            uo_out <= data_square_puls;
            data_valid_strobe <= data_square_puls_out_valid_strobe;
        end
    end

endmodule
