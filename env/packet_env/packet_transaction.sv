`ifndef __PACKET_TRANSACTION_SV__
`define __PACKET_TRANSACTION_SV__

class packet_transaction;

string name;
typedef enum {GOOD, BAD} head_type;
typedef enum {LONG, SHORT, NORMAL} packet_length;
rand head_type     pkt_head_type     ;
rand packet_length pkt_packet_length ;
rand logic [15:0] header     ;
rand logic [7:0 ] payload[$] ;
rand logic [6:0 ] frame_interval;

extern function new(string name = "Packet Transaction");
extern function void display(string prefix = "Note");
extern function bit compare(packet_transaction pkt2cmp, ref string message);
extern function void byte2pkt(ref logic[7:0] data[$]);
extern function packet_transaction copy();

constraint con_head_type {
    solve pkt_head_type before header;
    pkt_head_type dist {GOOD := 5, BAD := 1};
    (pkt_head_type == GOOD) -> (header == 16'h55d5);
    (pkt_head_type == BAD) -> (header inside {[0:16'h55d4], [16'h55d6:16'hffff]});
}

constraint con_pkt_len {
    solve pkt_packet_length before payload;
    pkt_packet_length dist {LONG := 1, SHORT := 1, NORMAL := 5};
    (pkt_packet_length == LONG) -> (payload.size() inside {[0:49]});
    (pkt_packet_length == SHORT) -> (payload.size() inside {[50:500]});
    (pkt_packet_length == NORMAL) -> (payload.size() inside {[501:600]});
}

constraint con_frame_interval {
    frame_interval inside {[96:200]};
}

endclass

function packet_transaction::new(string name);
    this.name = name;
endfunction

function bit packet_transaction::compare(packet_transaction pkt2cmp, ref string message);
    if(header != pkt2cmp.header) begin
        message = "Header Mismatch:\n";
        message = { message, $psprintf("Header Sent:  %p\nHeader Received: %p", header, pkt2cmp.header) };
        return(0);
    end

    if (payload.size() != pkt2cmp.payload.size()) begin
        message = "Payload Size Mismatch:\n";
        message = { message, $psprintf("payload.size() = %0d, pkt2cmp.payload.size() = %0d\n", payload.size(), pkt2cmp.payload.size()) };
        return(0);
    end

    if (payload == pkt2cmp.payload) ;
    else begin
        message = "Payload Content Mismatch:\n";
        message = { message, $psprintf("Packet Sent:  %p\nPkt Received: %p", payload, pkt2cmp.payload) };
        return(0);
    end

    message = "Successfully Compared";
    return(1);
endfunction

function void packet_transaction::display(string prefix);
    $display("[%s]%t %s", prefix, $realtime, name);
    $display("    [%s]%t %s frame_interval = %0d", prefix, $realtime, name, frame_interval);
    $display("    [%s]%t %s header = %0h", prefix, $realtime, name, header);
    foreach(payload[i])
        $display("    [%s]%t %s payload[%0d] = %0d", prefix, $realtime, name, i, payload[i]);
endfunction

function void packet_transaction::byte2pkt(ref logic[7:0] data[$]);
    if(data.size() >= 2) begin
        header[15:8] = data.pop_front();
        header[7:0]  = data.pop_front();
    end

    foreach(data[i]) begin
        payload.push_back(data[i]);
    end

endfunction

function packet_transaction packet_transaction::copy();
    packet_transaction pkt_tran = new();
    pkt_tran.frame_interval = this.frame_interval;
    pkt_tran.header = this.header;
    foreach(this.payload[i]) begin
        pkt_tran.payload.push_back(this.payload[i]);
    end

    return pkt_tran;
endfunction

`endif

