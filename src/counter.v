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

`ifndef __COUNTER
`define __COUNTER

module counter #(
    parameter N_FRAC = 7
) (
    input clk_i,
    input rst_i,
    input signed [N_FRAC:0] amplitude_i,
    input signed [N_FRAC:0] addend_i,
    input overflow_mode_i, 				
    input next_data_strobe_i,					
    output wire signed [N_FRAC:0] data_o,						
    output wire data_out_valid_strobe_o
);

    reg signed [N_FRAC:0] counter_value, next_counter_value;
    reg data_out_valid_strobe, next_data_out_valid_strobe;

    always @(posedge clk_i) begin
        if (rst_i == 1'b0) begin
            counter_value <= 0;
            data_out_valid_strobe <= 0;
        end else begin
            counter_value <= next_counter_value;
            data_out_valid_strobe <= next_data_out_valid_strobe;
        end
    end 

    always @* begin
        next_data_out_valid_strobe = 0;
        next_counter_value = counter_value;
        
        if (next_data_strobe_i == 1'b1) begin
            next_data_out_valid_strobe = 1;
            if ((overflow_mode_i == 1'b1) || (counter_value <= amplitude_i)) begin
                next_counter_value = counter_value + addend_i;
            end else begin
                next_counter_value = -counter_value;
            end
        end
    end

    assign data_o = counter_value;
    assign data_out_valid_strobe_o = data_out_valid_strobe;

endmodule

`endif
`default_nettype wire
