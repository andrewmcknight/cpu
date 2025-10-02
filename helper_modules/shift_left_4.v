// shift_left_4: Logical left shift by 4 bits for 32-bit inputs. Inputs: in. Outputs: out.

module shift_left_4(out, in);
    input [31:0] in;
    output [31:0] out;

    assign out = {in[27:0], 4'b0000};
endmodule
