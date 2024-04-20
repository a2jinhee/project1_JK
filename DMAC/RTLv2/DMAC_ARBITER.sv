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

    // mnemonics for state values
    localparam                  s_0  = 2'd0,
                                s_1  = 2'd1,
                                s_2  = 2'd2,
                                s_3  = 2'd3;

    reg     [1:0]               state,          state_n;
    reg     [31:0]              dst_data,       dst_data_n;
    reg                         dst_valid,      dst_valid_n;
    reg                         src_ready[N_MASTER], src_ready_n[N_MASTER];

    // it's desirable to code registers in a simple way
    always_ff @(posedge clk)
        if (!rst_n) begin
            state               <= s_0;
            dst_data            <= 32'd0;
            dst_valid           <= 1'b0;
            src_ready           <= '{N_MASTER{1'b0}};
        end
        else begin
            state               <= state_n;
            dst_data            <= dst_data_n;
            dst_valid           <= dst_valid_n;
            src_ready           <= src_ready_n;
        end

    always_comb begin
        state_n                 = state;
        dst_data_n              = dst_data;
        dst_valid_n             = dst_valid;
        src_ready_n             = src_ready;
        
        case (state)
        s_0:     begin
                $display("STATE: 0");
                $display("dst_ready_i: %d", dst_ready_i);
                $display("src_valid_i: %d%d%d%d", src_valid_i[0], src_valid_i[1], src_valid_i[2], src_valid_i[3]);
                $display("src_ready: %d%d%d%d", src_ready_n[0], src_ready_n[1], src_ready_n[2], src_ready_n[3]);
                
                if (src_valid_i[0]) begin
                    src_ready_n[0] = 1'b1;
                    dst_valid_n = 1'b1;
                    dst_data_n = src_data_i[0];
                end

                if (dst_ready_i) begin
                    if      (src_valid_i[1]) begin state_n = s_1; end
                    else if (src_valid_i[2]) begin state_n = s_2; end
                    else if (src_valid_i[3]) begin state_n = s_3; end
                    else if (src_valid_i[0]) begin state_n = s_0; end
                    else state_n = s_0; 
                end
                end


        s_1:    begin
                $display("STATE: 1");
                $display("dst_ready_i: %d", dst_ready_i);
                $display("src_valid_i: %d%d%d%d", src_valid_i[0], src_valid_i[1], src_valid_i[2], src_valid_i[3]);
                $display("src_ready: %d%d%d%d", src_ready[0], src_ready[1], src_ready[2], src_ready[3]);
                
                if (src_valid_i[1]) begin
                    src_ready_n[1] = 1'b1;
                    dst_valid_n = 1'b1;
                    dst_data_n = src_data_i[1];
                end
                if (dst_ready_i) begin
                    if      (src_valid_i[2]) begin state_n = s_2; end
                    else if (src_valid_i[3]) begin state_n = s_3; end
                    else if (src_valid_i[0]) begin state_n = s_0; end
                    else if (src_valid_i[1]) begin state_n = s_1; end
                    else state_n = s_1; 
                end
                end


        s_2:    begin
                $display("STATE: 2");
                $display("dst_ready_i: %d", dst_ready_i);
                $display("src_valid_i: %d%d%d%d", src_valid_i[0], src_valid_i[1], src_valid_i[2], src_valid_i[3]);
                $display("src_ready: %d%d%d%d", src_ready[0], src_ready[1], src_ready[2], src_ready[3]);
                if (src_valid_i[2]) begin
                    src_ready_n[2] = 1'b1;
                    dst_valid_n = 1'b1;
                    dst_data_n = src_data_i[2];
                end

                if (dst_ready_i) begin
                    if      (src_valid_i[3]) begin state_n = s_3; end
                    else if (src_valid_i[0]) begin state_n = s_0; end
                    else if (src_valid_i[1]) begin state_n = s_1; end
                    else if (src_valid_i[2]) begin state_n = s_2; end
                    else state_n = s_2;
                end
                end


        s_3:    begin
                $display("STATE: 3");
                $display("dst_ready_i: %d", dst_ready_i);
                $display("src_valid_i: %d%d%d%d", src_valid_i[0], src_valid_i[1], src_valid_i[2], src_valid_i[3]);
                $display("src_ready: %d%d%d%d", src_ready[0], src_ready[1], src_ready[2], src_ready[3]);
                if (src_valid_i[3]) begin
                    src_ready_n[3] = 1'b1;
                    dst_valid_n = 1'b1;
                    dst_data_n = src_data_i[3];
                end

                if (dst_ready_i) begin
                    if      (src_valid_i[0]) begin state_n = s_0; end
                    else if (src_valid_i[1]) begin state_n = s_1; end
                    else if (src_valid_i[2]) begin state_n = s_2; end
                    else if (src_valid_i[3]) begin state_n = s_3; end
                    else state_n = s_3;
                    end
                end
        endcase
    end

    assign  dst_data_o                = dst_data;
    assign  dst_valid_o               = dst_valid;
    assign  src_ready_o               = src_ready;

endmodule