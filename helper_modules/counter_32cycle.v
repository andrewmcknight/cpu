// counter_32cycle: 5-bit synchronous counter advancing on enabled clocks. Inputs: clk, en, clr. Outputs: q.

module counter_32cycle (
    output [4:0] q,
    input clk,
    input en,
    input clr
);
    
    // Instantiate 4 T flip-flops (LSB to MSB)
    tff tff0 (.q(q[0]), .t(1'b1), .clk(clk), .en(en), .clr(clr));           // LSB TFF toggles on every clk
    tff tff1 (.q(q[1]), .t(q[0]), .clk(clk), .en(en), .clr(clr));          // Toggles when q[0] = 1
    tff tff2 (.q(q[2]), .t(q[0] & q[1]), .clk(clk), .en(en), .clr(clr));          // Toggles when q[1] = 1
    tff tff3 (.q(q[3]), .t(q[0] & q[1] & q[2]), .clk(clk), .en(en), .clr(clr));
    tff tff4 (.q(q[4]), .t(q[0] & q[1] & q[2] & q[3]), .clk(clk), .en(en), .clr(clr));

endmodule
