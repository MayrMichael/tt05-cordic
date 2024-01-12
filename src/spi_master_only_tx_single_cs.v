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

`ifndef __SPI_MASTER_ONLY_TX_WITH_SINGLE_CS
`define __SPI_MASTER_ONLY_TX_WITH_SINGLE_CS

`include "spi_master_only_tx.v"

module spi_master_only_tx_single_cs #(
    parameter SPI_MODE = 0,
    parameter CLKS_PER_HALF_BIT = 2,
    parameter CS_INACTIVE_CLKS = 1
) (
    input clk_i,
    input rst_i,
    input [7:0] data_i, 
    input data_in_valid_strobe_i, 

    //SPI interface
    output wire spi_clk_o,
    output wire spi_mosi_o,
    output wire spi_cs_o
);
    localparam IDLE        = 2'b00;
    localparam TRANSFER    = 2'b01;
    localparam CS_INACTIVE = 2'b10;

    reg [1:0] state, next_state;
    reg cs, next_cs;
    wire tx_ready;

    reg cs_inactive_counter, next_cs_inactive_counter;

    spi_master_only_tx  
    #(.SPI_MODE(SPI_MODE),
      .CLKS_PER_HALF_BIT(CLKS_PER_HALF_BIT)
    ) 
    spi_master_only_tx_inst 
    (.clk_i(clk_i),
     .rst_i(rst_i),
     .data_i(data_i), 
     .data_in_valid_strobe_i(data_in_valid_strobe_i), 
     .tx_ready_o(tx_ready),
     .spi_clk_o(spi_clk_o),
     .spi_mosi_o(spi_mosi_o)
    );

    always @(posedge clk_i) begin
        if (rst_i == 1'b0) begin
            state <= IDLE;
            cs <= 1'b1;
            cs_inactive_counter <= CS_INACTIVE_CLKS;
        end else begin
            state <= next_state;
            cs <= next_cs;
            cs_inactive_counter <= next_cs_inactive_counter;
        end
    end

    always @* begin
        next_state = state;
        next_cs = cs;
        next_cs_inactive_counter = cs_inactive_counter;

        case (state)
            IDLE: begin
                if ((data_in_valid_strobe_i & cs) == 1'b1) begin
                    next_state = TRANSFER;
                    next_cs = 1'b0;
                end
            end
            TRANSFER: begin
                if (tx_ready == 1'b1) begin
                    next_cs = 1'b1;
                    next_cs_inactive_counter = CS_INACTIVE_CLKS;
                    next_state = CS_INACTIVE;
                end
            end
            CS_INACTIVE: begin
                if (cs_inactive_counter > 0) begin
                    next_cs_inactive_counter = cs_inactive_counter - 1'b1; 
                end else begin
                    next_state = IDLE;
                end
            end
            default: begin
                next_cs = 1'b1;
                next_state = IDLE;
            end
        endcase
    end

    assign spi_cs_o = cs;

endmodule

`endif
`default_nettype wire
