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
    wire                   [N_MASTER-1:0] grant;
    priority_encoder #( .N (N_MASTER) ) priority_encoder_inst (
        .clk(clk),
        .rst_n(rst_n),
        .i_vec(src_valid_i),
        .o_vec(grant)
    );

    // Round robin counter to handle priority ties
    reg                     [N_MASTER-1:0] round_robin_counter;
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
        round_robin_counter <= 0;
        end else if (dst_ready_i) begin
        // Increment counter only when data is transferred
        round_robin_counter <= round_robin_counter + 1'b1;
        end
    end

    // Combine grant with round robin counter for final arbiter output
    wire                   [N_MASTER-1:0] final_grant;
    generate
        for (genvar i = 0; i < N_MASTER; i = i + 1) begin
        assign final_grant[i] = grant[i] | (round_robin_counter == i);
        end
    endgenerate

    // Assign outputs based on final grant
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
        src_ready_o <= 'b0;
        dst_valid_o <= 1'b0;
        dst_data_o <= 'b0;
        end else begin
        src_ready_o <= final_grant;
        dst_valid_o = final_grant & dst_ready_i;  // Only send data when both ready
        dst_data_o = src_data_i[PriorityEncode(final_grant)];  // Select data based on granted master
        end
    end

    // Helper function to get the index of the highest bit in the grant vector
    function integer PriorityEncode;
        input logic [N_MASTER-1:0] vec;
        integer i;
        begin
        PriorityEncode = -1;
        for (i = 0; i < N_MASTER; i = i + 1) begin
            if (vec[i]) begin
            PriorityEncode = i;
            return;
            end
        end
        end
    endfunction


endmodule