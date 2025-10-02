module shift_right_4(out, in);
    input [31:0] in;
    output [31:0] out;

    assign out = {{4{in[31]}}, in[31:4]}; 
endmodule
