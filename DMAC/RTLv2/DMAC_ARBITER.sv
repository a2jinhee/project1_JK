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
    reg [1:0] present_state;
    reg [1:0] next_state;

    parameter [1:0] s_0 = 2'b00;
    parameter [1:0] s_1 = 2'b01;
    parameter [1:0] s_2 = 2'b10;
    parameter [1:0] s_3 = 2'b11;

    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            present_state <= s_0;
        end
        else begin
            present_state <= next_state;
        end
    end

    always @ (*) begin
        case (present_state)
        s_0:     begin
                if      (src_valid_i[1]) begin src_ready_o[1] = 1'b1; next_state = s_1; end
                else if (src_valid_i[2]) begin src_ready_o[2] = 1'b1; next_state = s_2; end
                else if (src_valid_i[3]) begin src_ready_o[3] = 1'b1; next_state = s_3; end
                else if (src_valid_i[0]) begin src_ready_o[0] = 1'b1; next_state = s_0; end
                else             next_state = s_ideal;
                end
        s_1:    begin
                if      (src_valid_i[2]) begin src_ready_o[2] = 1'b1; next_state = s_2; end
                else if (src_valid_i[3]) begin src_ready_o[3] = 1'b1; next_state = s_3; end
                else if (src_valid_i[0]) begin src_ready_o[0] = 1'b1; next_state = s_0; end
                else if (src_valid_i[1]) begin src_ready_o[1] = 1'b1; next_state = s_1; end
                else             next_state = s_ideal;
                end
        s_2:    begin
                if      (src_valid_i[3]) begin src_ready_o[3] = 1'b1; next_state = s_3; end
                else if (src_valid_i[0]) begin src_ready_o[0] = 1'b1; next_state = s_0; end
                else if (src_valid_i[1]) begin src_ready_o[1] = 1'b1; next_state = s_1; end
                else if (src_valid_i[2]) begin src_ready_o[2] = 1'b1; next_state = s_2; end
                else             next_state = s_ideal;
                end
        s_3:    begin
                if      (src_valid_i[0]) begin src_ready_o[0] = 1'b1; next_state = s_0; end
                else if (src_valid_i[1]) begin src_ready_o[1] = 1'b1; next_state = s_1; end
                else if (src_valid_i[2]) begin src_ready_o[2] = 1'b1; next_state = s_2; end
                else if (src_valid_i[3]) begin src_ready_o[3] = 1'b1; next_state = s_3; end
                else             next_state = s_ideal;
                end
        default: begin
                if      (src_valid_i[0]) begin src_ready_o[0] = 1'b1; next_state = s_0; end
                else if (src_valid_i[1]) begin src_ready_o[1] = 1'b1; next_state = s_1; end
                else if (src_valid_i[2]) begin src_ready_o[2] = 1'b1; next_state = s_2; end
                else if (src_valid_i[3]) begin vsrc_ready_o[3] = 1'b1; next_state = s_3; end
                else             next_state = s_ideal;
                end
        endcase
    end

    always @ (*) begin
        case (present_state)
            s_0: 
                if (src_ready[0] && dst_ready_i) begin
                    dst_valid_o = 1'b1;
                    dst_data_o = src_data_i[0];
                end
            s_1:
                if (src_ready[1] && dst_ready_i) begin
                    dst_valid_o = 1'b1;
                    dst_data_o = src_data_i[1];
                end
            s_2: 
                if (src_ready[2] && dst_ready_i) begin
                    dst_valid_o = 1'b1;
                    dst_data_o = src_data_i[2];
                end
            s_3: 
                if (src_ready[3] && dst_ready_i) begin
                    dst_valid_o = 1'b1;
                    dst_data_o = src_data_i[3];
                end
            default: 
                dst_valid_o = 1'b0;
                dst_data_o = 32'd0;
        endcase
    end

endmodule