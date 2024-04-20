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
    // src_valid_i : valid signal vector for each master = if 1, master has data to send
    // src_data_i :data signal vector for each master = (id, data, strb, last)
    // dst_ready_i :ready signal for selected slave = if 1, slave is ready to receive data

    // src_ready_o :ready signal vector for each master = if 1, master is ready to send data
    // dst_valid_o : valid signal for selected slave  = if 1, slave has data to receive
    // dst_data_o : data signal for slave = (id, data, strb, last)

    // Priority encoder to determine the highest priority requesting master
    // Round-robin arbiter logic
    reg [N_MASTER-1:0] next_master;
    reg [N_MASTER-1:0] current_master;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
        next_master <= 'b0;
        current_master <= 'b0;
        end else begin
        // Find the next valid master in a round-robin fashion
        next_master = next_master + 1'b1;
        while (~src_valid_i[next_master] && next_master != current_master) begin
            next_master = next_master + 1'b1;
            if (next_master == 3) begin
            next_master = 0;
            end
        end
        
        // Update current master only if a valid master is found
        if (src_valid_i[next_master]) begin
            current_master <= next_master;
        end
        end
    end

    // Grant access to the current master
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
        src_ready_o <= 'b0;
        end else begin
        src_ready_o <= src_valid_i & {N_MASTER{current_master}};  // One-hot encoded ready signal
        end
    end

    // Assign data from the current master to the output
    always @(posedge clk) begin
        if (dst_ready_i) begin
        dst_valid_o <= src_valid_i[current_master];
        dst_data_o <= src_data_i[current_master];
        end else begin
        dst_valid_o <= 1'b0;
        end
    end


endmodule