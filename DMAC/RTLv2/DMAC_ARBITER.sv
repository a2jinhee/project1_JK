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

    // TODO: implement ROUND ROBIN arbiter here
    // Internal signals
    reg [N_MASTER-1:0] selected_master;
    
    // Round-robin logic
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            selected_master <= 0; // Reset to master 0
            dst_valid_o <= 0;     // Reset valid output
        end
        else if (dst_ready_i) begin
            // Round-robin selection
            selected_master <= (selected_master == N_MASTER-1) ? 0 : selected_master + 1;
            dst_valid_o <= src_valid_i[selected_master];
            src_ready_o[selected_master] <= dst_valid_o;
            dst_data_o <= src_data_i[selected_master];
        end
    end


endmodule
