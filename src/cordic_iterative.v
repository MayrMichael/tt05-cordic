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
`ifndef __CORDIC_ITERATIVE
`define __CORDIC_ITERATIVE
`include "cordic_slice.v"

module cordic_iterative #(
    parameter N_FRAC = 7
) (
    input clk_i,
    input rst_i,
    input signed [N_FRAC:0] x_i,						
    input signed [N_FRAC:0] y_i,						
    input signed [N_FRAC:0] z_i,
    input data_in_valid_strobe_i, 						
    output wire signed [N_FRAC:0] x_o,						
    output wire signed [N_FRAC:0] y_o,						
    output wire signed [N_FRAC:0] z_o,
    output wire data_out_valid_strobe_o	
);
    //generated from cordic_param.py start
    localparam ITERATIONS = 6;
    localparam BW_SHIFT_VECTOR = 3;
    wire [BW_SHIFT_VECTOR-1:0] SHIFT_VECTOR [0:5];
    assign SHIFT_VECTOR[0] = 3'b000;
    assign SHIFT_VECTOR[1] = 3'b001;
    assign SHIFT_VECTOR[2] = 3'b010;
    assign SHIFT_VECTOR[3] = 3'b011;
    assign SHIFT_VECTOR[4] = 3'b100;
    assign SHIFT_VECTOR[5] = 3'b101;
    wire [7:0] ANGLES_VECTOR [0:5];
    assign ANGLES_VECTOR[0] = 8'b00100000;
    assign ANGLES_VECTOR[1] = 8'b00010010;
    assign ANGLES_VECTOR[2] = 8'b00001001;
    assign ANGLES_VECTOR[3] = 8'b00000101;
    assign ANGLES_VECTOR[4] = 8'b00000010;
    assign ANGLES_VECTOR[5] = 8'b00000001;
    // generated from cordic_param.py end

    // reg signed [N_FRAC:0] next_x_in, x_in;
    // reg signed [N_FRAC:0] next_y_in, y_in;
    // reg signed [N_FRAC:0] next_z_in, z_in;

    reg next_data_out_valid_strobe, data_out_valid_strobe;
    reg next_input_select, input_select;

    localparam IDLE_STATE = 2'b00;
    localparam CALCULATION_STATE = 2'b01;
    localparam OUTPUT_STATE = 2'b10;

    reg [1:0] next_state, state;
    
    localparam BW_COUNTER = $clog2(ITERATIONS);
    reg [BW_COUNTER-1 : 0] next_counter_value, counter_value;

    wire [N_FRAC:0] current_rotation_angle;
    wire [BW_SHIFT_VECTOR-1:0] shift_value;

    reg signed [N_FRAC:0] x_mux, y_mux, z_mux;
    wire signed [N_FRAC:0] x_out, y_out, z_out;

    always @(posedge clk_i) begin
        if (rst_i == 1'b0) begin
            // x_in <= 0;
            // y_in <= 0;
            // z_in <= 0;
            data_out_valid_strobe <= 0;
            counter_value <= 0;
            state <= IDLE_STATE;
            input_select <= 0;
        end else begin
            // x_in <= next_x_in;
            // y_in <= next_y_in;
            // z_in <= next_z_in;
            data_out_valid_strobe <= next_data_out_valid_strobe;
            counter_value <= next_counter_value;
            state <= next_state;
            input_select <= next_input_select;            
        end
    end



    assign current_rotation_angle = ANGLES_VECTOR[counter_value];
    assign shift_value = SHIFT_VECTOR[counter_value];

    cordic_slice #(.N_FRAC(N_FRAC), .BW_SHIFT_VALUE(BW_SHIFT_VECTOR)) cordic_slice0
    (.clk_i(clk_i),
     .rst_i(rst_i),
     .current_rotation_angle_i(current_rotation_angle),
     .shift_value_i(shift_value),
     .x_i(x_mux),
     .y_i(y_mux),
     .z_i(z_mux),
     .x_o(x_out),
     .y_o(y_out),
     .z_o(z_out)
     );


    

    always @* begin
        next_state = state;
        next_data_out_valid_strobe = data_out_valid_strobe;
        // next_x_in = x_in;
        // next_y_in = y_in;
        // next_z_in = z_in;
        next_counter_value = counter_value;
        next_input_select = input_select;

        case (state)
            IDLE_STATE: begin
                if (data_in_valid_strobe_i == 1'b1) begin
                    next_state = CALCULATION_STATE;
                    // next_x_in = x_i;
                    // next_y_in = y_i;
                    // next_z_in = z_i;
                    next_counter_value = 0;
                    next_input_select = 0;
                end
            end 
            CALCULATION_STATE: begin
                next_input_select = 1;
                if (counter_value == ITERATIONS-1) begin
                    next_state = OUTPUT_STATE;
                    next_data_out_valid_strobe = 1;
                end else begin
                    next_counter_value = counter_value + 1;
                end
            end
            OUTPUT_STATE: begin
                next_state = IDLE_STATE;
                next_data_out_valid_strobe = 0;
            end
            default:
                next_state = IDLE_STATE;
        endcase
    end

    assign x_o = x_out;
    assign y_o = y_out;
    assign z_o = z_out;
    assign data_out_valid_strobe_o = data_out_valid_strobe;

    always @* begin
        if (input_select == 1'b0) begin
            // x_mux = x_in;
            // y_mux = y_in;
            // z_mux = z_in;
            x_mux = x_i;
            y_mux = y_i;
            z_mux = z_i;
        end else begin
            x_mux = x_out;
            y_mux = y_out;
            z_mux = z_out;
        end
    end


endmodule

`endif
`default_nettype wire
