module tff (q, t, clk, en, clr);
   
   // Inputs
   input t, clk, en, clr;
   
   // Output
   output q;

   wire dffIn;
   assign dffIn = (t & !q) | (q & !t);
   dffe_ref dff(.q(q), .d(dffIn), .clk(clk), .en(en), .clr(clr));

endmodule
