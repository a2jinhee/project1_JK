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

    reg     [3:0]                       sel;
    reg                                 src_ready [N_MASTER];
    reg                                 dst_valid,  dst_valid_n;
    reg     [15:0]                      duty,   duty_n, duty_size;
    reg     [3:0]                       queue[0:3], queue_n[0:3];
    wire    [3:0]                       request = {src_valid_i[3],src_valid_i[2],src_valid_i[1],src_valid_i[0]};
    
    reg [DATA_SIZE-1:0]                 dst_data, dst_data_n;

    always_ff @(posedge clk) begin
        if(!rst_n) begin
            duty                         <=  0;
            duty_size                    <=  1;
            queue                        <= {{4'b0001},{4'b0010},{4'b0100},{4'b1000}};          
            dst_valid                    <= 1'b0;    
            dst_data                     <=  'b0;
        end
        else begin
            queue                       <= queue_n;
            duty                        <= duty_n;
            dst_valid                   <= dst_valid_n;
            dst_data                    <= dst_data_n;
        end     
/*      
        $display("%d) src_valid_i : %d %d %d %d", iid, src_valid_i[0], src_valid_i[1], src_valid_i[2], src_valid_i[3]);
        $display("%d) src_ready_o : %d %d %d %d", iid, src_ready[0], src_ready[1], src_ready[2], src_ready[3]);
        $display("%d) dst_valid_o , dst_ready_i, dst_valid_n : %d %d %d",iid, dst_valid,dst_ready_i, dst_valid_n);
        $display("%d) fifo_wdata, fifo_rdata, dst_data : %0x %0x %0x", iid, fifo_wdata, fifo_rdata, dst_data);
        $display("%d) fifo : %0x %0x %0x %0x", iid, queue[0],queue[1],queue[2],queue[3]);

        $display("%d) src_valid_i : %d %d %d %d", iid, src_valid_i[0], src_valid_i[1], src_valid_i[2], src_valid_i[3]);
        $display("%d) src_ready_0 : %d %d %d %d", iid, src_ready[0], src_ready[1], src_ready[2], src_ready[3]);
        $display("%d) dst_valid_o : %d", iid, dst_valid);
        $display("%d) duty : %d", iid, duty);
*/
    end

    always_comb begin
        duty_n                          =   duty ;
        queue_n                         =   queue;
        sel                             =   4'b0;
        src_ready                       =   {{0},{0},{0},{0}};
        dst_data_n                      =   dst_data;
        dst_valid_n                     =   dst_valid;

        if( !((queue[0] & request) == 4'b0000) )   begin
            sel                         =   (queue[0] == 4'b0001) ? 0 :
                                            (queue[0] == 4'b0010) ? 1 :
                                            (queue[0] == 4'b0100) ? 2 : 3;
            if( ((dst_ready_i == 1'b1) & (dst_valid == 1'b1)) | (dst_valid == 1'b0)) begin
                src_ready[sel]              =   1;
                dst_data_n                  =   src_data_i[sel];
                dst_valid_n                 =   1'b1;       
                if(duty == 0) begin
                    duty_n                      =   duty_size;
                    queue_n                     =   {{queue[1]},{queue[2]},{queue[3]},{queue[0]}};                
                end         
                else begin
                    duty_n                      =   duty - 1;
                end
            end 
        end
        else if( !((queue[1] & request) == 4'b0000) )   begin
            sel                         =   (queue[1] == 4'b0001) ? 0 :
                                            (queue[1] == 4'b0010) ? 1 :
                                            (queue[1] == 4'b0100) ? 2 : 3;
            if( ((dst_ready_i == 1'b1) & (dst_valid == 1'b1)) | (dst_valid == 1'b0)) begin
                src_ready[sel]              =   1;
                dst_data_n                  =   src_data_i[sel];
                dst_valid_n                 =   1'b1;                
                if(duty == 0) begin
                    duty_n                      =   duty_size;                
                    queue_n                     =   {{queue[0]},{queue[2]},{queue[3]},{queue[1]}};           
                end
                else begin
                    duty_n                      =   duty - 1;
                end                
            end
        end
        else if( !((queue[2] & request) == 4'b0000) )   begin
            sel                         =   (queue[2] == 4'b0001) ? 0 :
                                            (queue[2] == 4'b0010) ? 1 :
                                            (queue[2] == 4'b0100) ? 2 : 3;
            if( ((dst_ready_i == 1'b1) & (dst_valid == 1'b1)) | (dst_valid == 1'b0)) begin
                src_ready[sel]              =   1;
                dst_data_n                  =   src_data_i[sel];
                dst_valid_n                 =   1'b1;
                if(duty == 0) begin
                    duty_n                      =   duty_size;                
                    queue_n                     =   {{queue[0]},{queue[1]},{queue[3]},{queue[2]}};          
                end
                else begin
                    duty_n                      =   duty - 1;
                end                
            end
        end
        else if( !((queue[3] & request) == 4'b0000) )   begin
            sel                         =   (queue[3] == 4'b0001) ? 0 :
                                            (queue[3] == 4'b0010) ? 1 :
                                            (queue[3] == 4'b0100) ? 2 : 3;
            if( ((dst_ready_i == 1'b1) & (dst_valid == 1'b1)) | (dst_valid == 1'b0)) begin
                src_ready[sel]              =   1;
                dst_data_n                  =   src_data_i[sel];
                dst_valid_n                 =   1'b1;                
                if(duty == 0) begin
                    duty_n                      =   duty_size;                
                    queue_n                     =   {{queue[0]},{queue[1]},{queue[2]},{queue[3]}};    
                end
                else begin
                    duty_n                      =   duty - 1;
                end                
            end                
        end
        else if( (request == 4'b0000) & (dst_ready_i == 1'b1) & (dst_valid == 1'b1) ) begin
            dst_valid_n                     =   1'b0;
        end 
       
        if( (request == 4'b0000 ) | ((dst_ready_i == 1'b0) & (dst_valid == 1'b1 ) ) )begin
           if(duty == 0)begin
                duty_n                          =    'b0;
            end
            else begin
                duty_n                          =    duty - 1;
            end
        end
    end

    assign  dst_valid_o         =   dst_valid;
    assign  dst_data_o          =   dst_data;
    assign  src_ready_o         =   src_ready;

endmodule
