// shift_right_8: Arithmetic right shift by 8 bits for 32-bit inputs. Inputs: in. Outputs: out.

module shift_right_8(out, in);
    input [31:0] in;
    output [31:0] out;

    assign out = {{8{in[31]}}, in[31:8]};
endmodule
