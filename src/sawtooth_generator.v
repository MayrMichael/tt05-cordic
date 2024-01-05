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

`ifndef __SAWTOOTH_GENERATOR
`define __SAWTOOTH_GENERATOR

module sawtooth_generator #(
    parameter N_FRAC = 7
) (
    input clk_i,
    input rst_i,
    input signed [N_FRAC:0] amplitude_i,
    input signed [N_FRAC:0] counter_value_i,			
    input next_counter_value_strobe_i, 						
    output wire signed [N_FRAC:0] data_o,						
    output wire data_out_valid_strobe_o
);

    reg signed [N_FRAC:0] data, next_data;
    reg data_out_valid_strobe, next_data_out_valid_strobe;

    /* verilator lint_off UNUSEDSIGNAL */
    wire signed [(N_FRAC*2)+1:0] mul_result;
    /* verilator lint_on UNUSEDSIGNAL */

    always @(posedge clk_i) begin
        if (rst_i == 1'b0) begin
            data <= 0;
            data_out_valid_strobe <= 0;
        end else begin
            data <= next_data;
            data_out_valid_strobe <= next_data_out_valid_strobe;
        end
    end
    
    assign mul_result = counter_value_i * amplitude_i;

    always @* begin
        next_data_out_valid_strobe = 0;
        next_data = data;
        
        if (next_counter_value_strobe_i == 1'b1) begin
            next_data_out_valid_strobe = 1;
            next_data = mul_result[N_FRAC*2:N_FRAC];
        end
    end

    assign data_o = data;
    assign data_out_valid_strobe_o = data_out_valid_strobe;

endmodule

`endif
`default_nettype wire
