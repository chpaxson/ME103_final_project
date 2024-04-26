module Queue(
  input         clock,
                reset,
  output        io_enq_ready,	// @[src/main/scala/chisel3/util/Decoupled.scala:273:14]
  input         io_enq_valid,	// @[src/main/scala/chisel3/util/Decoupled.scala:273:14]
  input  [63:0] io_enq_bits,	// @[src/main/scala/chisel3/util/Decoupled.scala:273:14]
  input         io_deq_ready,	// @[src/main/scala/chisel3/util/Decoupled.scala:273:14]
  output        io_deq_valid,	// @[src/main/scala/chisel3/util/Decoupled.scala:273:14]
  output [63:0] io_deq_bits,	// @[src/main/scala/chisel3/util/Decoupled.scala:273:14]
  output [5:0]  io_count	// @[src/main/scala/chisel3/util/Decoupled.scala:273:14]
);

  reg  [5:0] enq_ptr_value;	// @[src/main/scala/chisel3/util/Counter.scala:61:40]
  reg  [5:0] deq_ptr_value;	// @[src/main/scala/chisel3/util/Counter.scala:61:40]
  reg        maybe_full;	// @[src/main/scala/chisel3/util/Decoupled.scala:277:27]
  wire       ptr_match = enq_ptr_value == deq_ptr_value;	// @[src/main/scala/chisel3/util/Counter.scala:61:40, src/main/scala/chisel3/util/Decoupled.scala:278:33]
  wire       empty = ptr_match & ~maybe_full;	// @[src/main/scala/chisel3/util/Decoupled.scala:277:27, :278:33, :279:{25,28}]
  wire       full = ptr_match & maybe_full;	// @[src/main/scala/chisel3/util/Decoupled.scala:277:27, :278:33, :280:24]
  wire       do_enq = ~full & io_enq_valid;	// @[src/main/scala/chisel3/util/Decoupled.scala:52:35, :280:24, :304:19]
  wire       do_deq = io_deq_ready & ~empty;	// @[src/main/scala/chisel3/util/Decoupled.scala:52:35, :279:25, :303:19]
  always @(posedge clock) begin
    if (reset) begin
      enq_ptr_value <= 5'h0;	// @[src/main/scala/chisel3/util/Counter.scala:61:40]
      deq_ptr_value <= 5'h0;	// @[src/main/scala/chisel3/util/Counter.scala:61:40]
      maybe_full <= 1'h0;	// @[src/main/scala/chisel3/util/Decoupled.scala:277:27]
    end
    else begin
      if (do_enq)	// @[src/main/scala/chisel3/util/Decoupled.scala:52:35]
        enq_ptr_value <= enq_ptr_value + 5'h1;	// @[src/main/scala/chisel3/util/Counter.scala:61:40, :77:24]
      if (do_deq)	// @[src/main/scala/chisel3/util/Decoupled.scala:52:35]
        deq_ptr_value <= deq_ptr_value + 5'h1;	// @[src/main/scala/chisel3/util/Counter.scala:61:40, :77:24]
      if (~(do_enq == do_deq))	// @[src/main/scala/chisel3/util/Decoupled.scala:52:35, :277:27, :294:{15,27}, :295:16]
        maybe_full <= do_enq;	// @[src/main/scala/chisel3/util/Decoupled.scala:52:35, :277:27]
    end
  end // always @(posedge)
  
  ram_64x64 ram_ext (	// @[src/main/scala/chisel3/util/Decoupled.scala:274:95]
    .R0_addr (deq_ptr_value),	// @[src/main/scala/chisel3/util/Counter.scala:61:40]
    .R0_en   (1'h1),
    .R0_clk  (clock),
    .R0_data (io_deq_bits),
    .W0_addr (enq_ptr_value),	// @[src/main/scala/chisel3/util/Counter.scala:61:40]
    .W0_en   (do_enq),	// @[src/main/scala/chisel3/util/Decoupled.scala:52:35]
    .W0_clk  (clock),
    .W0_data (io_enq_bits)
  );
  assign io_enq_ready = ~full;	// @[src/main/scala/chisel3/util/Decoupled.scala:280:24, :304:19]
  assign io_deq_valid = ~empty;	// @[src/main/scala/chisel3/util/Decoupled.scala:279:25, :303:19]
  assign io_count = {maybe_full & ptr_match, enq_ptr_value - deq_ptr_value};	// @[src/main/scala/chisel3/util/Counter.scala:61:40, src/main/scala/chisel3/util/Decoupled.scala:277:27, :278:33, :327:32, :330:{32,62}]
endmodule



module ram_64x64(	// @[src/main/scala/chisel3/util/Decoupled.scala:274:95]
  input  [5:0]  R0_addr,
  input         R0_en,
                R0_clk,
  output [63:0] R0_data,
  input  [5:0]  W0_addr,
  input         W0_en,
                W0_clk,
  input  [63:0] W0_data
);

  reg [63:0] Memory[0:63];	// @[src/main/scala/chisel3/util/Decoupled.scala:274:95]
  always @(posedge W0_clk) begin	// @[src/main/scala/chisel3/util/Decoupled.scala:274:95]
    if (W0_en & 1'h1)	// @[src/main/scala/chisel3/util/Decoupled.scala:274:95]
      Memory[W0_addr] <= W0_data;	// @[src/main/scala/chisel3/util/Decoupled.scala:274:95]
  end // always @(posedge)

  assign R0_data = R0_en ? Memory[R0_addr] : 64'bx;	// @[src/main/scala/chisel3/util/Decoupled.scala:274:95]
endmodule