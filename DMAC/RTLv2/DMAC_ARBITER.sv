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

    reg [1:0] current_master = 0; // Counter to keep track of the current master

    // Arbiter logic
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            // Reset all signals
            dst_valid_o <= 0;
            src_ready_o <= {N_MASTER{1'b0}};
            dst_data_o <= DATA_SIZE'b0;
            current_master <= 0;
        end else begin
            // Round-robin arbitration
            if (dst_ready_i) begin
                // Find the next master with valid data
                for (int i = 0; i < N_MASTER; i = i + 1) begin
                    current_master <= (current_master + 1) % N_MASTER;
                    if (src_valid_i[current_master]) begin
                        // Grant access to the selected master
                        src_ready_o[current_master] <= 1;
                        dst_valid_o <= 1;
                        dst_data_o <= src_data_i[current_master];
                        // Exit loop after granting access
                        break;
                    end
                end
            end else begin
                // No destination ready, reset all source ready signals
                src_ready_o <= {N_MASTER{1'b0}};
            end
        end
    end

    


endmodule