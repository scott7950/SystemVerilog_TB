`timescale 1ns/1ps

`define PKT_RECV_IDLE   0
`define PKT_RECV_START  1
`define PKT_RECV_RECV   2
`define PKT_RECV_VALID  3
`define PKT_RECV_END    4

`define PKT_SENT_IDLE   0
`define PKT_SENT_VALID  1
`define PKT_SENT_END    2
`define PKT_SENT_FIN    3

module dut(
    clk    ,
    rst_n  ,

    addr   ,
    din    ,
    rw     ,
    dout   ,

    txd    ,
    tx_vld ,
    rxd    ,
    rx_vld   
);

input         clk    ;
input         rst_n  ;

input  [7:0 ] addr  ;
input  [31:0] din   ;
input         rw    ;
output [31:0] dout  ;

input  [7:0 ] rxd    ;
input         rx_vld ;
output [7:0 ] txd    ;
output        tx_vld ;

wire        clk   ;
wire        rst_n ;

wire [7:0 ] addr  ;
wire [31:0] din   ;
wire        rw    ;
reg  [31:0] dout  ;

wire [7:0 ] rxd    ;
wire        rx_vld ;
reg  [7:0 ] txd    ;
reg         tx_vld ;

wire        write ;
wire        read  ;

wire [31:0] config_reg ;
reg         pkt_en;
reg  [31:0] min_pkt_size ;
reg  [31:0] max_pkt_size ;

reg  [7:0 ] mem[0:512];
reg  [9:0 ] mem_wr_ptr;
reg  [9:0 ] mem_rd_ptr;
reg  [9:0 ] need_to_sent_pkt_size;
reg  [9:0 ] sending_pkt_size;

reg  [2:0 ] pkt_recv_status;
reg  [1:0 ] pkt_sent_status;

reg         new_pkt;
reg         one_pkt_sent;

reg  [1:0 ] pkt_no;

assign write = (rw == 1'b0);
assign read  = (rw == 1'b1);

assign config_reg = {31'h0, pkt_en};

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        pkt_en <= 1'b0;
    end
    else begin
        if((addr == 8'h0) && (write == 1'b1)) begin
            pkt_en <= din[0];
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        min_pkt_size <= 32'd64;
    end
    else begin
        if((addr == 8'h4) && (write == 1'b1)) begin
            if((din[9:0] >= 64) && (din[9:0] < max_pkt_size[9:0]))
                min_pkt_size[9:0] <= din[9:0];
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        max_pkt_size <= 32'd512;
    end
    else begin
        if((addr == 8'h8) && (write == 1'b1)) begin
            if((din[9:0] <= 512) && (din[9:0] > min_pkt_size[9:0]))
                max_pkt_size[9:0] <= din[9:0];
        end
    end
end

always @(*) begin
    case(addr)
        8'h0    : dout = config_reg;
        8'h4    : dout = min_pkt_size;
        8'h8    : dout = max_pkt_size;
        default : dout = 32'h0;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        pkt_recv_status <= 'h0;
        pkt_recv_status <= `PKT_RECV_IDLE;
        mem_wr_ptr <= 8'h0;
        new_pkt    <= 1'b0;
    end
    else begin
        case(pkt_recv_status)
            `PKT_RECV_IDLE: begin
                mem_wr_ptr <= 8'h0;
                if((rx_vld == 1'b1) && (pkt_en == 1'b1)) begin
                    mem_wr_ptr <= mem_wr_ptr + 1;
                    pkt_recv_status <= `PKT_RECV_START;
                    mem[mem_wr_ptr] <= rxd;
                end
            end
            `PKT_RECV_START: begin
                if(rx_vld == 1'b1) begin
                    mem_wr_ptr <= mem_wr_ptr + 1;
                    pkt_recv_status <= `PKT_RECV_RECV;
                    mem[mem_wr_ptr] <= rxd;
                end
                else begin
                    pkt_recv_status <= `PKT_RECV_END;
                end
            end
            `PKT_RECV_RECV: begin
                if(rx_vld == 1'b1) begin
                    if(mem_wr_ptr == max_pkt_size) begin
                        pkt_recv_status <= `PKT_RECV_END;
                    end
                    else begin
                        mem_wr_ptr <= mem_wr_ptr + 1;
                        pkt_recv_status <= `PKT_RECV_RECV;
                        mem[mem_wr_ptr] <= rxd;
                    end
                end
                else begin
                    pkt_recv_status <= `PKT_RECV_VALID;
                end
            end
            `PKT_RECV_VALID: begin
                if(mem_wr_ptr >= min_pkt_size) begin
                    new_pkt <= 1'b1;
                    need_to_sent_pkt_size <= mem_wr_ptr;
                end
                pkt_recv_status <= `PKT_RECV_END;
            end
            `PKT_RECV_END: begin
                new_pkt <= 1'b0;
                if(rx_vld == 1'b0) begin
                    pkt_recv_status <= `PKT_RECV_IDLE;
                end
            end
            default : begin
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        pkt_sent_status <= `PKT_SENT_IDLE;
        pkt_sent_status <= 'h0;
        mem_rd_ptr <= 'h0;
        sending_pkt_size <= 'h0;
        txd <= 'h0;
        tx_vld <= 1'b0;
        one_pkt_sent <= 1'b0;
    end
    else begin
        case(pkt_sent_status)
            `PKT_SENT_IDLE: begin
                if(pkt_no > 0) begin
                    pkt_sent_status <= `PKT_SENT_VALID;
                    sending_pkt_size <= need_to_sent_pkt_size;
                    mem_rd_ptr <= 'h0;
                end
            end
            `PKT_SENT_VALID: begin
                if(mem_rd_ptr < sending_pkt_size) begin
                    mem_rd_ptr <= mem_rd_ptr + 1;
                    txd <= mem[mem_rd_ptr];
                    tx_vld <= 1'b1;
                end
                else begin
                    pkt_sent_status <= `PKT_SENT_END;
                    txd <= 'h0;
                    tx_vld <= 1'b0;
                end
            end
            `PKT_SENT_END: begin
                pkt_sent_status <= `PKT_SENT_FIN;
                one_pkt_sent <= 1'b1;
            end
            `PKT_SENT_FIN: begin
                pkt_sent_status <= `PKT_SENT_IDLE;
                one_pkt_sent <= 1'b0;
            end
            default: begin
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        pkt_no <= 'h0;
    end
    else begin
        if(new_pkt == 1'b1) begin
            pkt_no <= pkt_no + 1;
        end
        else if(one_pkt_sent == 1'b1) begin
            pkt_no <= pkt_no - 1;
        end
    end
end

endmodule

