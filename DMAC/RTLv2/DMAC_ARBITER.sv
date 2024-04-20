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

    /// Arbitration logic
    reg [N_MASTER-1:0] current_master;
    reg [N_MASTER-1:0] next_master;
    reg                transfer_complete;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_master <= 0;
            next_master <= 0;
            dst_valid_o <= 0;
            transfer_complete <= 1'b1; // Initialize to ensure the first transaction can start
        end else begin
            // Increment the counter to select the next master only if the transfer is complete
            if (transfer_complete && dst_ready_i) begin
                next_master <= (current_master == N_MASTER - 1) ? 0 : current_master + 1;
            end
        end
    end

    always @* begin
        // Check if any source is ready and select the current master
        src_ready_o[current_master] = src_valid_i[current_master] && transfer_complete;
        // Assign data from the selected master to the destination only if both source and destination are ready
        if (src_ready_o[current_master] && dst_ready_i) begin
            dst_data_o <= src_data_i[current_master];
            dst_valid_o <= src_valid_i[current_master];
            transfer_complete <= 1'b0; // Indicate that a transfer is ongoing
        end
        // Reset transfer_complete when both source and destination are ready and data has been transferred
        if (dst_ready_i && !src_ready_o[current_master]) begin
            transfer_complete <= 1'b1;
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            current_master <= 0;
        end else if (dst_ready_i && transfer_complete) begin
            current_master <= next_master;
        end
    end

endmodule
