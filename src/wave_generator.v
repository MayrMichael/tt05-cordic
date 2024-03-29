// Copyright 2023 Michael Mayr
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE−2.0
//
// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

`default_nettype none

`ifndef __WAVE_GENERATOR
`define __WAVE_GENERATOR

`include "sin_generator.v"
`include "top_triangle_generator.v"
`include "strobe_generator.v"

module wave_generator #(
    parameter N_FRAC = 7
) (
    input clk_i,
    input rst_i,
    input enable_i,
    input [1:0] waveform_i,
    input set_phase_strobe_i,
    input set_amplitude_strobe_i,
    input signed [N_FRAC:0] data_i,
    output wire signed [N_FRAC:0] data_o,
    output wire data_valid_strobe_o
);
    wire signed [N_FRAC:0] data_sin, data_triangle, data_sawtooth, data_square_puls;
    wire data_sin_out_valid_strobe, data_triangle_out_valid_strobe, data_sawtooth_out_valid_strobe,  data_square_puls_out_valid_strobe;

    reg signed [N_FRAC:0] phase;
    wire signed [N_FRAC:0] next_phase;

    reg signed [N_FRAC:0] amplitude;
    wire signed [N_FRAC:0] next_amplitude;


    reg data_valid_strobe;
    reg signed [N_FRAC:0] data;

    wire strobe;
    wire overflow_mode;

    localparam SINUS = 2'b00;
    localparam SQUARE_PULSE = 2'b01;
    localparam SAWTOOTH = 2'b10;
    localparam TRIANGLE = 2'b11;

    assign overflow_mode = waveform_i == SQUARE_PULSE ? 1'b1 : 1'b0;

    strobe_generator strobe_generator_inst
    (.clk_i(clk_i),
     .rst_i(rst_i),
     .enable_i(enable_i),
     .strobe_o(strobe)
    );

    sin_generator sin_generator_inst
    (.clk_i(clk_i),
     .rst_i(rst_i),
     .phase_i(phase),
     .amplitude_i(amplitude),
     .next_data_strobe_i(strobe),
     .data_o(data_sin),
     .data_out_valid_strobe_o(data_sin_out_valid_strobe)
    );

    top_triangle_generator top_triangle_generator_inst
    (.clk_i(clk_i),
     .rst_i(rst_i),
     .phase_i(phase),
     .amplitude_i(amplitude),
     .overflow_mode_i(overflow_mode),					
     .next_data_strobe_i(strobe), 						
     .data_sawtooth_o(data_sawtooth),						
     .data_sawtooth_out_valid_strobe_o(data_sawtooth_out_valid_strobe),
     .data_triangle_o(data_triangle),						
     .data_triangle_out_valid_strobe_o(data_triangle_out_valid_strobe),
     .data_square_puls_o(data_square_puls),
     .data_square_puls_out_valid_strobe_o(data_square_puls_out_valid_strobe)
    );

    always @(posedge clk_i) begin
        if (rst_i == 1'b0) begin
            data <= 0;
            data_valid_strobe <= 0;
            phase <= 0;
            amplitude <= 0;
        end else begin
            phase <= next_phase;
            amplitude <= next_amplitude;
            case (waveform_i)
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

    assign next_phase = (set_phase_strobe_i == 1'b1) ? data_i : phase;
    assign next_amplitude = (set_amplitude_strobe_i == 1'b1) ? data_i : amplitude; 

    assign data_o = data;
    assign data_valid_strobe_o = data_valid_strobe;

endmodule

`endif
`default_nettype wire
