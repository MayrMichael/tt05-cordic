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

`include "wave_generator.v"

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
    wire data_valid_strobe;
    wire [7:0] data;

    wire set_phase, set_amplitude;

    wire [7:0] set_phase_amplitude_value;
    wire enable;
    wire [1:0] waveform;

    assign set_phase_amplitude_value = ui_in;
    
    assign uo_out = data;

    assign uio_oe = 8'b11100000;
    assign uio_out[7] = sclk;
    assign uio_out[6] = sdo;
    assign uio_out[5] = cs;
    assign uio_out[4:0] = 5'b00000;

    assign enable = uio_in[0];
    assign waveform = uio_in[2:1];
    assign set_phase = uio_in[3];
    assign set_amplitude = uio_in[4];

    wire sclk;

    reg sdo, cs;
    reg next_sdo, next_cs;
    reg [2:0] next_counter, counter;

    reg state, next_state;

    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            sdo <= 0;
            cs <= 1;
            counter <= 0;
            state <= 0;
        end else begin
            sdo <= next_sdo;
            cs <= next_cs;
            counter <= next_counter;
            state <= next_state;
        end
    end

    assign sclk = (state == 1'b1) ? clk : 1'b1;

    always @* begin
        next_cs = cs;
        next_sdo = sdo;
        next_state = state;
        next_counter = counter;

        if (state == 1'b0) begin
            if (data_valid_strobe == 1'b1) begin
                next_cs = 0;
                next_counter = 0;
                next_state = 1'b1;
            end
        end else begin
            next_counter = counter + 1;
            next_sdo = data[counter];

            if (counter == 3'b111) begin
                next_cs = 1;
                next_state = 0;
            end
        end
    end

    wave_generator wave_generator_inst
    (
    .clk_i(clk),
    .rst_i(rst_n),
    .enable_i(enable),
    .waveform_i(waveform),
    .set_phase_strobe_i(set_phase),
    .set_amplitude_strobe_i(set_amplitude),
    .data_i(set_phase_amplitude_value),
    .data_o(data),
    .data_valid_strobe_o(data_valid_strobe)
    );

endmodule
