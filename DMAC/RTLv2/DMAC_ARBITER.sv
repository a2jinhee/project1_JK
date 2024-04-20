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
    reg [N_MASTER-1:0] chosen_src;
    reg [DATA_SIZE-1:0] chosen_data;
    reg chosen_valid;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset state
            chosen_src <= 0;
            chosen_data <= 0;
            chosen_valid <= 0;
            for (int i = 0; i < N_MASTER; i = i + 1) begin
                src_ready_o[i] <= 0;
            end
            dst_valid_o <= 0;
            dst_data_o <= 0;
        end else begin
            // Round-robin priority scheme
            chosen_src <= chosen_src + 1;
            if (chosen_src >= N_MASTER) begin
                chosen_src <= 0; // Wrap around
            end

            // Check if the chosen source has valid data and is ready to transmit
            if (src_valid_i[chosen_src] && !src_ready_o[chosen_src]) begin
                chosen_data <= src_data_i[chosen_src];
                chosen_valid <= 1;
                src_ready_o[chosen_src] <= 1;
            end

            // Check if destination is ready to receive data
            if (chosen_valid && dst_ready_i) begin
                dst_valid_o <= 1;
                dst_data_o <= chosen_data;
                chosen_valid <= 0;
            end
        end
    end


endmodule