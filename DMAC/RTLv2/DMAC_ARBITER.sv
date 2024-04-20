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

always @* begin
    // Find the next valid master
    integer i;
    for (i = 0; i < N_MASTER; i = i + 1) begin
        if (src_valid_i[next_master]) begin
            // Next master is valid, grant access to it
            src_ready_o[next_master] = 1;
            break;
        end else begin
            // Move to the next master
            next_master = (next_master == N_MASTER - 1) ? 0 : next_master + 1;
        end
    end

    // Reset src_ready_o for all masters except the current one
    for (i = 0; i < N_MASTER; i = i + 1) begin
        if (i != current_master) begin
            src_ready_o[i] = 0;
        end
    end

    // Check if any master is ready to send data
    if (src_ready_o[current_master]) begin
        // Transfer data to destination
        dst_data_o = src_data_i[current_master];
        dst_valid_o = 1;
    end else begin
        // No master is ready, keep destination invalid
        dst_valid_o = 0;
    end
end

endmodule
