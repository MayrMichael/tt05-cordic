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

`ifndef __SPI_MASTER_ONLY_TX
`define __SPI_MASTER_ONLY_TX

module spi_master_only_tx #(
    parameter SPI_MODE = 0,
    parameter CLKS_PER_HALF_BIT = 2
) (
    input clk_i,
    input rst_i,
    input [7:0] data_i, 
    input data_in_valid_strobe_i, 
    output wire tx_ready_o, // Transmit Ready for next byte

    //SPI interface
    output wire spi_clk_o,
    output wire spi_mosi_o
);

    wire clk_polarity;
    wire clk_phase; 

    reg [$clog2(CLKS_PER_HALF_BIT*2)-1:0] spi_clk_counter, next_spi_clk_counter;
    reg spi_clk, next_spi_clk;
    reg spi_clk_additional;
    wire next_spi_clk_additional;

    reg [4:0] spi_clk_edges, next_spi_clk_edges;

    reg leading_edge, next_leading_edge;
    reg trailing_edge, next_trailing_edge;

    reg [2:0] tx_bit_counter, next_tx_bit_counter;

    reg spi_mosi, next_spi_mosi;
    reg tx_ready, next_tx_ready;

    reg data_in_valid_strobe;
    wire next_data_in_valid_strobe;

    // CPOL: Clock Polarity
    // CPOL=0 means clock idles at 0, leading edge is rising edge.
    // CPOL=1 means clock idles at 1, leading edge is falling edge.
    assign clk_polarity  = (SPI_MODE == 2) | (SPI_MODE == 3);

    // CPHA: Clock Phase
    // CPHA=0 means the "out" side changes the data on trailing edge of clock
    //              the "in" side captures data on leading edge of clock
    // CPHA=1 means the "out" side changes the data on leading edge of clock
    //              the "in" side captures data on the trailing edge of clock
    assign clk_phase  = (SPI_MODE == 1) | (SPI_MODE == 3);


    always @(posedge clk_i) begin
        if (rst_i == 1'b0) begin
            tx_ready <= 0;
            spi_clk_edges <= 0;
            leading_edge <= 0;
            trailing_edge <= 0;
            spi_clk <= clk_polarity;
            spi_clk_counter <= 0;

            spi_mosi <= 1'b0;
            tx_bit_counter <= 3'b111; // send MSb first

            spi_clk_additional  <= clk_polarity;

            data_in_valid_strobe <= 0;
        end else begin
            tx_ready <= next_tx_ready;
            spi_clk_edges <= next_spi_clk_edges;
            leading_edge <= next_leading_edge;
            trailing_edge <= next_trailing_edge;
            spi_clk <= next_spi_clk;
            spi_clk_counter <= next_spi_clk_counter;

            spi_mosi <= next_spi_mosi;
            tx_bit_counter <= next_tx_bit_counter; // send MSb first

            spi_clk_additional  <= next_spi_clk_additional;

            data_in_valid_strobe <= next_data_in_valid_strobe;
        end
    end

    assign next_spi_clk_additional = spi_clk;

    assign spi_clk_o = spi_clk_additional;
    assign spi_mosi_o = spi_mosi;
    assign tx_ready_o = tx_ready;


    assign next_data_in_valid_strobe = data_in_valid_strobe_i;
    

    always @* begin
        next_leading_edge = 1'b0;
        next_trailing_edge = 1'b0;
        next_spi_clk_edges = spi_clk_edges;
        next_spi_clk_counter = spi_clk_counter;
        next_spi_clk = spi_clk;
        next_tx_ready = tx_ready;

        if (data_in_valid_strobe_i == 1'b1) begin
            next_tx_ready = 1'b0;
            next_spi_clk_edges = 16;
        end else if (spi_clk_edges > 0) begin
            next_tx_ready = 1'b0;

            if (spi_clk_counter == CLKS_PER_HALF_BIT*2-1) begin
                next_spi_clk_edges = spi_clk_edges - 1'b1;
                next_trailing_edge = 1'b1;
                next_spi_clk_counter = 0;
                next_spi_clk = ~spi_clk;
            end else if (spi_clk_counter == CLKS_PER_HALF_BIT-1) begin
                next_spi_clk_edges = spi_clk_edges - 1'b1;
                next_leading_edge = 1'b1;
                next_spi_clk_counter = spi_clk_counter + 1'b1;
                next_spi_clk = ~spi_clk;
            end else begin
                next_spi_clk_counter = spi_clk_counter + 1'b1;
            end
        end else begin
            next_tx_ready = 1'b1;
        end
    end

    always @* begin
        next_tx_bit_counter = tx_bit_counter;
        next_spi_mosi = spi_mosi;

        if (tx_ready == 1'b1) begin
            next_tx_bit_counter = 3'b111;
            next_spi_mosi = 0;
        end else if ((data_in_valid_strobe & ~clk_phase) == 1'b1) begin
            next_spi_mosi = data_i[3'b111];
            next_tx_bit_counter = 3'b110;
        end else if ((leading_edge & clk_phase) | (trailing_edge & ~clk_phase) == 1'b1) begin
            if (tx_bit_counter > 0) begin
                next_tx_bit_counter = tx_bit_counter - 1'b1;
            end
            next_spi_mosi = data_i[tx_bit_counter];
        end
    end
    
endmodule

`endif
`default_nettype wire
