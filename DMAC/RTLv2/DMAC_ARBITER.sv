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


endmodule