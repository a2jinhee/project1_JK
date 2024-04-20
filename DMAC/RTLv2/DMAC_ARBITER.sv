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
    reg [N_MASTER-1:0] current_master;
    reg [N_MASTER-1:0] selected_master;
    reg data_sent;
    reg destination_ready;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            // Reset all variables
            current_master <= 0;
            selected_master <= 0;
            data_sent <= 0;
            destination_ready <= 0;
            dst_valid_o <= 0;
            dst_data_o <= 0;
            src_ready_o <= 0;
        end else begin
            // Check if any source is valid and ready to send data
            for (current_master = 0; current_master < N_MASTER; current_master = current_master + 1) begin
                if (src_valid_i[current_master] && src_ready_o[current_master]) begin
                    selected_master <= current_master;
                    break;
                end
            end

            // Check if destination is ready to receive data
            destination_ready <= dst_ready_i;

            // Send data from the selected_master to the destination
            if (destination_ready && !data_sent) begin
                dst_data_o <= src_data_i[selected_master];
                dst_valid_o <= 1;
                src_ready_o[selected_master] <= 0;
                data_sent <= 1;
            end

            // Reset data_sent flag and dst_valid_o if the destination confirms receipt of data
            if (destination_ready && data_sent && dst_ready_i) begin
                data_sent <= 0;
                dst_valid_o <= 0;
            end

            // Reset data_sent flag and dst_valid_o if the destination is not ready
            if (!destination_ready) begin
                data_sent <= 0;
                dst_valid_o <= 0;
            end
        end
    end


endmodule