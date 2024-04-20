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

    // Arbiter shoots src_ready_o=1 in a round robin way
    // if src_valid_i=1 when arbiter shoots src_ready_o=1 to corresponding slave, arbiter selects the slave
    
    // if dst_ready_i=1, arbiter shoots dst_valid_o=1 to the selected slave
    // get data from the selected slave and send it to the dst_data_o

    reg [N_MASTER-1:0] round_robin_counter;

    // Round-robin logic
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            round_robin_counter <= 0;
            src_ready_o <= {N_MASTER{1'b0}}; // Initialize all src_ready_o signals to 0
        end else begin
            if (dst_ready_i && dst_valid_o) begin
                // If the destination is ready and data was consumed, move to the next round
                round_robin_counter <= (round_robin_counter + 1) % N_MASTER;
            end
        end
    end

    // Assign src_ready_o in a round-robin manner
    always @* begin
        for (integer i = 0; i < N_MASTER; i = i + 1) begin
            if (i == round_robin_counter && src_valid_i[i]) begin
                src_ready_o[i] = 1'b1;
            end else begin
                src_ready_o[i] = 1'b0;
            end
        end
    end

    // When destination is ready, grant access to selected slave
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            dst_valid_o <= 1'b0;
        end else begin
            if (dst_ready_i && src_ready_o[round_robin_counter]) begin
                dst_valid_o <= 1'b1;
            end
        end
    end

    // Data transfer logic
    always @(posedge clk) begin
        if (dst_ready_i && src_ready_o[round_robin_counter] && dst_valid_o) begin
            dst_data_o <= src_data_i[round_robin_counter];
        end
    end


endmodule