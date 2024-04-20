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

    // Internal signals
    reg [N_MASTER-1:0] highest_priority;
    reg [N_MASTER-1:0] pending_request;

    // Initialize
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            highest_priority <= 0;
            pending_request <= 0;
            dst_valid_o <= 0;
            dst_data_o <= 0;
            src_ready_o <= 0;
        end else begin
            // Priority encoder for determining highest priority master
            for (int i = 0; i < N_MASTER; i++) begin
                if (src_valid_i[i]) begin
                    highest_priority <= i;
                    pending_request <= pending_request | (1 << i);
                end
            end
        end
    end

    // Arbitration logic
    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            dst_valid_o <= 0;
            dst_data_o <= 0;
            src_ready_o <= 0;
        end else if (dst_ready_i == 1'b1 && |pending_request) begin
            // Select the highest priority master with valid data
            dst_valid_o <= 1;
            dst_data_o <= src_data_i[highest_priority];
            src_ready_o[highest_priority] <= 1;
            // Reset pending request for the selected master
            pending_request <= pending_request & ~(1 << highest_priority);
        end else begin
            dst_valid_o <= 0;
            src_ready_o <= 1;
        end
    end




endmodule