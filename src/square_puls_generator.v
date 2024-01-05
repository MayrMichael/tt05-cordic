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

`ifndef __SQUARE_PULS_GENERATOR
`define __SQUARE_PULS_GENERATOR

`include "counter.v"

module square_puls_generator #(
    parameter N_FRAC = 7
) (
    input clk_i,
    input rst_i,
    input signed [N_FRAC:0] phase_i,
    input signed [N_FRAC:0] threshold_i,			
    input next_data_strobe_i, 						
    output wire signed [N_FRAC:0] data_o,						
    output wire data_out_valid_strobe_o
);

    reg signed [N_FRAC:0] data, next_data;
    reg data_out_valid_strobe, next_data_out_valid_strobe;

    wire counter_value_valid_strobe;
    wire signed [N_FRAC:0] counter_value;

    localparam ONE = 8'b0111_1111;
    localparam MINUS_ONE = 8'b1000_0001; 

    counter counter_inst
    (.clk_i(clk_i),
     .rst_i(rst_i),
     .addend_i(phase_i),			
     .next_data_strobe_i(next_data_strobe_i), 						
     .data_o(counter_value),						
     .data_out_valid_strobe_o(counter_value_valid_strobe)
    );

    always @(posedge clk_i) begin
        if (rst_i == 1'b0) begin
            data <= 0;
            data_out_valid_strobe <= 0;
        end else begin
            data <= next_data;
            data_out_valid_strobe <= next_data_out_valid_strobe;
        end
    end 

    always @* begin
        next_data_out_valid_strobe = 0;
        next_data = data;
        
        if (counter_value_valid_strobe == 1'b1) begin
            next_data_out_valid_strobe = 1;
            if (counter_value >= threshold_i) begin
                next_data = ONE;
            end else begin
                next_data = MINUS_ONE;
            end
        end
    end

    assign data_o = data;
    assign data_out_valid_strobe_o = data_out_valid_strobe;

endmodule

`endif
`default_nettype wire
