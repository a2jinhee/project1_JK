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

    // TODO: implement fixted priority arbiter
    // priority : ch0 > ch1 > ch2 > ch3
    // ch0 ends earliest. ch3 ends last. 

    // // Priority encoder to determine the highest priority channel
    // wire    [N_MASTER-1:0]     priority;
    // assign  priority = src_valid_i; // Priority based on the valid signals

    // always @ (posedge clk or negedge rst_n) begin
    //     if (~rst_n) begin
    //         // Reset
    //         dst_valid_o <= 0;
    //         dst_data_o <= 0;
    //         src_ready_o <= 0;
    //     end else begin
    //         // Arbitration logic
    //         case (priority)
    //             N_MASTER'b0001: begin // Channel 0 has the highest priority
    //                 if (dst_ready_i && src_valid_i[0]) begin
    //                     dst_valid_o <= 1;
    //                     dst_data_o <= src_data_i[0];
    //                     src_ready_o[0] <= 1;
    //                     for (int i = 1; i < N_MASTER; i++) begin
    //                         src_ready_o[i] <= 0;
    //                     end
    //                 end
    //             end
    //             N_MASTER'b0010: begin // Channel 1 has the highest priority
    //                 if (dst_ready_i && src_valid_i[1]) begin
    //                     dst_valid_o <= 1;
    //                     dst_data_o <= src_data_i[1];
    //                     src_ready_o[1] <= 1;
    //                     for (int i = 0; i < N_MASTER; i+=2) begin
    //                         src_ready_o[i] <= 0;
    //                     end
    //                 end
    //             end
    //             // Add cases for higher priority channels as needed
    //             // You can repeat the above pattern for other channels
    //             default: begin // No channel has valid data
    //                 dst_valid_o <= 0;
    //             end
    //         endcase
    //     end
    // end

endmodule
