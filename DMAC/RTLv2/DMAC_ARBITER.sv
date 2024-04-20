// Copyright (c) 2021 Sungkyunkwan University
//
// Authors:
// - Jungrae Kim <dale40@skku.edu>

module DMAC_ARBITER
#(
    N_MASTER                    = 4,
    DATA_SIZE                   = 32,
	TYPE						= 0
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

	// registers & parameters
    localparam                  S_0  = 2'b00,
                                S_1  = 2'b01,
                                S_2  = 2'b10,
                                S_3  = 2'b11;

    reg     [1:0]               state;
	reg		[1:0]				state_n;
	
	// sequential logic
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state               <= S_0;
        end
        else begin
            state               <= state_n;
        end
	end
	
	// combinational logic
	always_comb begin
		state_n = state;
		
		dst_valid_o		= 0;
		src_ready_o 	= '{N_MASTER{1'b0}};
		
		//$display("\TYPE: %d, nstate: %d, dst_data: %x, dst_ready_i: %d", TYPE, state, dst_data_o, dst_ready_i);
		//$display("src_valid: %d, %d, %d, %d", src_valid_i[0], src_valid_i[1], src_valid_i[2], src_valid_i[3]);
		
		case (state)
            S_0: begin
				// 0번 채널의 요청 처리
				dst_data_o = src_data_i[0];
				dst_valid_o = src_valid_i[0] ? 1 : 0;
				src_ready_o[0] = dst_ready_i ? 1 : 0;
				
				// RR 순서 처리
				if(!dst_valid_o) begin
					if(src_valid_i[1]) 		state_n = S_1;
					else if(src_valid_i[2]) state_n = S_2;
					else if(src_valid_i[3]) state_n = S_3;
					else 					state_n = S_0;
				end
			end
            S_1: begin
				// 1번 채널의 요청 처리
				dst_data_o = src_data_i[1];
				dst_valid_o = src_valid_i[1] ? 1 : 0;
				src_ready_o[1] = dst_ready_i ? 1 : 0;
				
				// RR 순서 처리
				if(!dst_valid_o) begin
					if(src_valid_i[2]) 		state_n = S_2;
					else if(src_valid_i[3]) state_n = S_3;
					else if(src_valid_i[0]) state_n = S_0;
					else 					state_n = S_1;
				end
			end
			S_2: begin
				// 2번 채널의 요청 처리
				dst_data_o = src_data_i[2];
				dst_valid_o = src_valid_i[2] ? 1 : 0;
				src_ready_o[2] = dst_ready_i ? 1 : 0;
				
				// RR 순서 처리
				if(!dst_valid_o) begin
					if(src_valid_i[3]) 		state_n = S_3;
					else if(src_valid_i[0]) state_n = S_0;
					else if(src_valid_i[1]) state_n = S_1;
					else 					state_n = S_2;
				end
			end
			S_3: begin
				// 3번 채널의 요청 처리
				dst_data_o = src_data_i[3];
				dst_valid_o = src_valid_i[3] ? 1 : 0;
				src_ready_o[3] = dst_ready_i ? 1 : 0;
				
				// RR 순서 처리
				if(!dst_valid_o) begin
					if(src_valid_i[0]) 		state_n = S_0;
					else if(src_valid_i[1]) state_n = S_1;
					else if(src_valid_i[2]) state_n = S_2;
					else 					state_n = S_3;
				end
			end
		endcase
		//$display("state: %d, state_n: %d\n", state, state_n);
	end

endmodule
