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
    reg [N_MASTER-1:0] current_master;
    reg [N_MASTER-1:0] next_master;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_master <= 0;
            next_master <= 0;
            dst_valid_o <= 0;
        end else begin
            // Increment the counter to select the next master
            if (dst_ready_i) begin
                next_master <= (current_master == N_MASTER - 1) ? 0 : current_master + 1;
            end
        end
    end

    always @* begin
    integer i;
    // Default values
    dst_valid_o = 0;
    current_master = N_MASTER; // Initialize to an invalid value
    
    // Priority-based arbitration
    for (i = 0; i < N_MASTER; i = i + 1) begin
        if (src_valid_i[i] && !src_ready_o[i]) begin
            // If the master is requesting and it's not granted, grant access to this master
            dst_valid_o = 1;
            current_master = i;
            // Exit the loop after granting access to the highest priority master
            break;
        end
    end
end


    always @(posedge clk) begin
        if (!rst_n) begin
            current_master <= 0;
        end else if (dst_ready_i) begin
            current_master <= next_master;
        end
    end


endmodule
