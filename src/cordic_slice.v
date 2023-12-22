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
`ifndef __CORDIC_SLICE
`define __CORDIC_SLICE

module cordic_slice #(
    parameter BW_SHIFT_VALUE = 4,
    parameter N_FRAC = 15
) (
    input clk_i,
    input rst_i,
    input signed [N_FRAC:0] current_rotation_angle_i,	
    input [BW_SHIFT_VALUE-1:0] shift_value_i,				
    input signed [N_FRAC:0] x_i,						
    input signed [N_FRAC:0] y_i,						
    input signed [N_FRAC:0] z_i,						
    output reg signed [N_FRAC:0] x_o,						
    output reg signed [N_FRAC:0] y_o,						
    output reg signed [N_FRAC:0] z_o						
);
    reg signed [N_FRAC:0] next_x;
    reg signed [N_FRAC:0] next_y;
    reg signed [N_FRAC:0] next_z;


    always @(posedge clk_i) begin
        if (rst_i == 1'b0) begin
            x_o <= 0;
            y_o <= 0;
            z_o <= 0;
        end else begin
            x_o <= next_x;
            y_o <= next_y;
            z_o <= next_z;            
        end
    end

    always @* begin
        next_x = x_i;
	    next_y = y_i;
	    next_z = z_i;

        if (z_i < 0) begin
            next_x = x_i + (y_i >>> shift_value_i);
            next_y = y_i - (x_i >>> shift_value_i);
		    next_z = z_i + current_rotation_angle_i;
        end else begin
            next_x = x_i - (y_i >>> shift_value_i);
            next_y = y_i + (x_i >>> shift_value_i);
		    next_z = z_i - current_rotation_angle_i;
        end
    end

endmodule

`endif
`default_nettype wire
