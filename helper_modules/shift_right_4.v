// shift_right_4: Arithmetic right shift by 4 bits for 32-bit inputs. Inputs: in. Outputs: out.

module shift_right_4(out, in);
    input [31:0] in;
    output [31:0] out;

    assign out = {{4{in[31]}}, in[31:4]}; 
endmodule
