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

    // TODO: implement your arbiter here
    // - The arbiter should be able to select one of the masters.
    // - The arbiter should be able to transfer data from the selected master to the slave.
    // - The arbiter should be able to handle the ready/valid signals
    // - Keep in mind that src_valid_i, dst_ready_i is INPUT, and src_ready_o, dst_valid_o is OUTPUT.
    reg [N_MASTER-1:0] selected_master;
    reg [DATA_SIZE-1:0] selected_data;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            selected_master <= 0;
            selected_data <= 0;
            dst_valid_o <= 0;
            src_ready_o <= {N_MASTER{1'b0}};
        end else begin
            // Priority-based selection
            for (int i = 0; i < N_MASTER; i = i + 1) begin
                if (src_valid_i[i] && dst_ready_i) begin
                    selected_master <= i;
                    selected_data <= src_data_i[i];
                    dst_valid_o <= 1;
                    src_ready_o[i] <= 1;
                end
            end
        end
    end

    always @(posedge clk) begin
        if (dst_ready_i && dst_valid_o) begin
            dst_data_o <= selected_data;
            dst_valid_o <= 0;
            src_ready_o[selected_master] <= 0;
        end
    end

endmodule