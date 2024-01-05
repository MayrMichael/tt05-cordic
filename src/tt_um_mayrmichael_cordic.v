`default_nettype none


`include "sin_generator.v"
`include "top_triangle_generator.v"
`include "strobe_generator.v"
`include "square_puls_generator.v"


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
    wire [7:0] phase, amplitude;
    wire [7:0] data_sin, data_triangle, data_sawtooth, data_square_puls;
    wire data_sin_out_valid_strobe, data_triangle_out_valid_strobe, data_sawtooth_out_valid_strobe,  data_square_puls_out_valid_strobe;

    reg data_valid_strobe;
    reg [7:0] data;

    wire strobe;
    wire set_phase, set_amplitude;

    wire [7:0] set_phase_amplitude_value;
    wire enable;
    wire [1:0] waveform;

    localparam SINUS = 2'b00;
    localparam SQUARE_PULSE = 2'b01;
    localparam SAWTOOTH = 2'b10;
    localparam TRIANGLE = 2'b11;

    assign set_phase_amplitude_value = ui_in;
    
    assign uo_out = data;

    assign uio_oe = 8'b10000000;
    assign uio_out[7] = data_valid_strobe;
    assign uio_out[6:0] = 7'b0000000;

    assign enable = uio_in[0];
    assign waveform = uio_in[2:1];
    assign set_phase = uio_in[3];
    assign set_amplitude = uio_in[4];
    //assign get_phase = uio_in[5];
    //assign get_amplitude = uio_in[6];

    strobe_generator strobe_generator_inst
    (.clk_i(clk),
     .rst_i(rst_n),
     .enable_i(enable),
     .strobe_o(strobe)
    );

    sin_generator sin_generator_inst
    (.clk_i(clk),
     .rst_i(rst_n),
     .phase_i(set_phase_amplitude_value),
     .new_phase_valid_strobe_i(set_phase),
     .amplitude_i(set_phase_amplitude_value),
     .new_amplitude_valid_strobe_i(set_amplitude),
     .next_data_strobe_i(strobe),
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
     .next_data_strobe_i(strobe), 						
     .data_sawtooth_o(data_sawtooth),						
     .data_sawtooth_out_valid_strobe_o(data_sawtooth_out_valid_strobe),
     .data_triangle_o(data_triangle),						
     .data_triangle_out_valid_strobe_o(data_triangle_out_valid_strobe)//,
//     .data_square_puls_o(data_square_puls),						
//     .data_square_puls_out_valid_strobe_o(data_square_puls_out_valid_strobe)		
    );

    square_puls_generator square_puls_generator_inst
    (.clk_i(clk),
     .rst_i(rst_n),
     .phase_i(phase),
     .threshold_i(amplitude),		
     .next_data_strobe_i(strobe), 						
     .data_o(data_square_puls),						
     .data_out_valid_strobe_o(data_square_puls_out_valid_strobe)
    );


    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            data <= 0;
            data_valid_strobe <= 0;
        end else begin
            case (waveform)
                SINUS: begin
                    data_valid_strobe <= data_sin_out_valid_strobe;
                    if (data_sin_out_valid_strobe == 1'b1) 
                        data <= data_sin;
                end 
                SAWTOOTH: begin
                    data_valid_strobe <= data_sawtooth_out_valid_strobe;
                    if (data_sawtooth_out_valid_strobe == 1'b1) 
                        data <= data_sawtooth;
                end
                TRIANGLE: begin
                    data_valid_strobe <= data_triangle_out_valid_strobe;
                    if (data_triangle_out_valid_strobe == 1'b1) 
                        data <= data_triangle;
                end
                SQUARE_PULSE: begin
                    data_valid_strobe <= data_square_puls_out_valid_strobe;
                    if (data_square_puls_out_valid_strobe == 1'b1) 
                        data <= data_square_puls;
                end
            endcase
        end
    end

endmodule
