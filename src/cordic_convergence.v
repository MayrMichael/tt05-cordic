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
`ifndef __CORDIC_CONVERGENCE
`define __CORDIC_CONVERGENCE

module cordic_convergence #(
    parameter N_FRAC = 7
) (
    input clk_i,
    input rst_i,
    input signed [N_FRAC:0] x_i,						
    input signed [N_FRAC:0] y_i,						
    input signed [N_FRAC:0] z_i,
    input data_in_valid_strobe_i, 						
    output reg signed [N_FRAC:0] x_o,						
    output reg signed [N_FRAC:0] y_o,						
    output reg signed [N_FRAC:0] z_o,
    output reg data_out_valid_strobe_o	
);
    localparam signed HALF = 8'b01000000;
    localparam signed MINUS_HALF = 8'b11000000;

    wire next_data_out_valid_strobe;
    reg signed [N_FRAC:0] next_x;
    reg signed [N_FRAC:0] next_y;
    reg signed [N_FRAC:0] next_z;

    always @(posedge clk_i) begin
        if (rst_i == 1'b0) begin
            x_o <= 0;
            y_o <= 0;
            z_o <= 0;
            data_out_valid_strobe_o <= 0;
        end else begin
            x_o <= next_x;
            y_o <= next_y;
            z_o <= next_z;
            data_out_valid_strobe_o <= next_data_out_valid_strobe;          
        end
    end

    assign next_data_out_valid_strobe = data_in_valid_strobe_i;

    always @* begin
        next_x = x_i;
        next_y = y_i;
        next_z = z_i;


        if (z_i > HALF) begin
            // is rotation greater than 0.5 pi? yes: rotate by hand 90° and subtract from z
            next_x = -y_i;
            next_y = x_i;
            next_z = MINUS_HALF + z_i;
        end else if (z_i < MINUS_HALF) begin
            // is rotation smaller than -0.5 pi? yes: rotate by hand -90° and add to z
            next_x = y_i;
            next_y = -x_i;
            next_z = HALF + z_i;            
        end
    end
    
endmodule

`endif
`default_nettype wire
