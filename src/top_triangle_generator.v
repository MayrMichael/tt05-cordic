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

`ifndef __TOP_TRIANGLE_GENERATOR
`define __TOP_TRIANGLE_GENERATOR

`include "counter.v"
`include "triangle_generator.v"
`include "square_puls_generator.v"

module top_triangle_generator #(
    parameter N_FRAC = 7
) (
    input clk_i,
    input rst_i,
    input signed [N_FRAC:0] phase_i,
    input signed [N_FRAC:0] amplitude_i,
    input overflow_mode_i,			
    input next_data_strobe_i, 						
    output wire signed [N_FRAC:0] data_sawtooth_o,						
    output wire data_sawtooth_out_valid_strobe_o,
    output wire signed [N_FRAC:0] data_triangle_o,						
    output wire data_triangle_out_valid_strobe_o,
    output wire signed [N_FRAC:0] data_square_puls_o,						
    output wire data_square_puls_out_valid_strobe_o	
);
    wire signed [N_FRAC:0] counter_value;
    wire counter_value_valid_strobe;

    counter counter_inst
    (.clk_i(clk_i),
     .rst_i(rst_i),
     .amplitude_i(amplitude_i),
     .addend_i(phase_i),
     .overflow_mode_i(overflow_mode_i),			
     .next_data_strobe_i(next_data_strobe_i), 						
     .data_o(counter_value),						
     .data_out_valid_strobe_o(counter_value_valid_strobe)
    );

    assign data_sawtooth_out_valid_strobe_o = counter_value_valid_strobe;
    assign data_sawtooth_o = counter_value;

   triangle_generator triangle_generator_inst
    (.clk_i(clk_i),
     .rst_i(rst_i),
     .counter_value_i(counter_value),			
     .next_counter_value_strobe_i(counter_value_valid_strobe), 						
     .data_o(data_triangle_o),						
     .data_out_valid_strobe_o(data_triangle_out_valid_strobe_o)
    );

    square_puls_generator square_puls_generator_inst
    (.clk_i(clk_i),
     .rst_i(rst_i),
     .threshold_i(amplitude_i),
     .counter_value_i(counter_value),		
     .counter_value_valid_strobe_i(counter_value_valid_strobe), 						
     .data_o(data_square_puls_o),						
     .data_out_valid_strobe_o(data_square_puls_out_valid_strobe_o)
    );

endmodule

`endif
`default_nettype wire
