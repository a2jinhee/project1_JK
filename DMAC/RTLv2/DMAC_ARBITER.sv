// Copyright (c) 2021 Sungkyunkwan University
//
// Authors:
// - Jungrae Kim <dale40@skku.edu>

module DMAC_ARBITER
#(
    N_MASTER                    = 4,
    DATA_SIZE                   = 32
)
(
    input   wire                clk,
    input   wire                rst_n,  // _n means active low

    // configuration registers
    input   wire                src_valid_i[N_MASTER],
    output  reg                 src_ready_o[N_MASTER],
    input   wire    [DATA_SIZE-1:0]     src_data_i[N_MASTER],

    output  reg                 dst_valid_o,
    input   wire                dst_ready_i,
    output  reg     [DATA_SIZE-1:0] dst_data_o
);

    // // TODO: implement your arbiter here
    reg [N_MASTER-1:0] round_robin_counter = 0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            round_robin_counter <= 0;
            dst_valid_o <= 0;
        end else begin
            if (dst_ready_i && dst_valid_o) begin
                dst_valid_o <= 0;
                round_robin_counter <= (round_robin_counter == N_MASTER - 1) ? 0 : round_robin_counter + 1;
            end else begin
                dst_valid_o <= src_valid_i[round_robin_counter];
            end
        end
    end

    assign src_ready_o = (dst_valid_o && !dst_ready_i) ? 1'b0 : src_valid_i;

    always @* begin
        dst_data_o = src_data_i[round_robin_counter];
    end

endmodule