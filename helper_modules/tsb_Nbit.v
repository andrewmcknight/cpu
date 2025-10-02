module tsb_Nbit #(parameter N = 32) (out, in, oe);

    input oe;
    input [N-1 : 0] in;
    output [N-1 : 0] out;

    assign out = oe? in:{N{1'bz}};

endmodule