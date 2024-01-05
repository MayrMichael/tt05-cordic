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

`ifndef __TRIANGLE_GENERATOR
`define __TRIANGLE_GENERATOR

module triangle_generator #(
    parameter N_FRAC = 7
) (
    input clk_i,
    input rst_i,
    input signed [N_FRAC:0] counter_value_i,			
    input next_counter_value_strobe_i, 						
    output wire signed [N_FRAC:0] data_o,						
    output wire data_out_valid_strobe_o
);

    reg signed [N_FRAC:0] data, next_data;
    reg data_out_valid_strobe, next_data_out_valid_strobe;
    reg reverse, next_reverse;
    reg old_signed_bit, next_old_signed_bit;
    reg counter, next_counter;

    reg state, next_state;

    localparam IDLE_STATE = 1'b0;
    localparam CALCULATION_STATE = 1'b1;

    always @(posedge clk_i) begin
        if (rst_i == 1'b0) begin
            state <= IDLE_STATE;
            old_signed_bit <= 0;
            counter <= 0;
            reverse <= 0;
            data <= 0;
            data_out_valid_strobe <= 0;
        end else begin
            state <= next_state;
            old_signed_bit <= next_old_signed_bit;
            counter <= next_counter;
            reverse <= next_reverse;
            data <= next_data;
            data_out_valid_strobe <= next_data_out_valid_strobe;
        end
    end

    always @* begin
        next_state = state;
        next_old_signed_bit = old_signed_bit;
        next_counter = counter;
        next_reverse = reverse;
        next_data = data;
        next_data_out_valid_strobe = 0;

        case (state)
            IDLE_STATE: begin
                if (next_counter_value_strobe_i == 1'b1) begin
                    next_state = CALCULATION_STATE;
                    next_old_signed_bit = counter_value_i[N_FRAC];
                    if (old_signed_bit != counter_value_i[N_FRAC]) begin
                        if (counter == 1'b0) begin
                            next_counter = 1;
                            next_reverse = ~reverse;
                        end else begin
                            next_counter = 0;
                        end
                    end
                end
            end 
            CALCULATION_STATE: begin
                next_data_out_valid_strobe = 1;
                next_state = IDLE_STATE;
                if (reverse == 1'b1) begin
                    next_data = -counter_value_i;
                end else begin
                    next_data = counter_value_i;
                end
            end
            default:
                next_state = IDLE_STATE;
        endcase
    end

    assign data_o = data;
    assign data_out_valid_strobe_o = data_out_valid_strobe;



endmodule

`endif
`default_nettype wire
