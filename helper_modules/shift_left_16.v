// shift_left_16: Logical left shift by 16 bits for 32-bit inputs. Inputs: in. Outputs: out.

module shift_left_16(out, in);
    input [31:0] in;
    output [31:0] out;

    assign out = {in[15:0], 16'b0000000000000000};
endmodule
