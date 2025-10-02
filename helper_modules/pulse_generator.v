// pulse_generator: Emits a one-cycle pulse when input_event rises. Inputs: input_event, clock, reset. Outputs: pulse.

module pulse_generator(pulse, input_event, clock, reset);
    input input_event, clock, reset;
    output pulse;
    wire q;
    dffe_ref dff(.q(q), .d(input_event), .clk(clock), .en(1'b1), .clr(reset));
    assign pulse = input_event && ~q;
endmodule
