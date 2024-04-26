module VectorToSingle(
  input         clock,
                reset,
  output        io_in_ready,	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:23:14]
  input         io_in_valid,	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:23:14]
  input  [63:0] io_in_bits,	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:23:14]
  input         io_out_ready,	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:23:14]
  output        io_out_valid,	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:23:14]
  output [7:0]  io_out_bits	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:23:14]
);

  reg  [3:0]      counter;	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:31:24]
  reg  [63:0]     data;	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:32:21]
  reg             reading;	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:33:24]
  wire            _io_in_ready_output = ~reading | counter == 4'h7;	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:31:24, :33:24, :37:{18,27,37,53}]
  wire            _GEN = reading & io_out_ready;	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:33:24, :56:25]
  wire [7:0][7:0] _GEN_0 = {{data[63:56]}, {data[55:48]}, {data[47:40]}, {data[39:32]}, {data[31:24]}, {data[23:16]}, {data[15:8]}, {data[7:0]}};	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:32:21, :57:17, generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/internal/utils.scala:38:8]
  wire            _GEN_1 = io_in_valid & _io_in_ready_output;	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:37:27, :41:21]
  wire            _GEN_2 = counter == 4'h7;	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:31:24, :37:53, :46:17]
  wire            _GEN_3 = _GEN_2 & ~_GEN_1;	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:41:21, :46:{17,40,42}]
  wire            _GEN_4 = _GEN_2 & io_in_valid & _io_in_ready_output;	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:37:27, :46:17, :51:54]
  always @(posedge clock) begin
    if (reset) begin
      counter <= 4'h0;	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:31:24]
      data <= 64'h0;	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:32:21]
      reading <= 1'h0;	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:33:24]
    end
    else begin
      if (_GEN_2)	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:46:17]
        counter <= 4'h0;	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:31:24]
      else if (_GEN)	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:56:25]
        counter <= counter + 4'h1;	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:31:24, :58:24]
      else if (_GEN_4 | _GEN_3)	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:31:24, :46:{40,72}, :47:13, :51:{54,69}, :52:13]
        counter <= 4'h0;	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:31:24]
      if (_GEN_1)	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:41:21]
        data <= io_in_bits;	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:32:21]
      reading <= _GEN_4 | ~_GEN_3 & (_GEN_1 | reading);	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:33:24, :41:{21,36}, :43:13, :46:{40,72}, :48:13, :51:{54,69}, :53:13]
    end
  end // always @(posedge)
  
  
  assign io_in_ready = _io_in_ready_output;	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:37:27]
  assign io_out_valid = reading;	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:33:24]
  assign io_out_bits = _GEN ? _GEN_0[counter[2:0]] : 8'h0;	// @[generators/dsp-near-mem-conv/src/main/scala/dspnearmemconv/DSPConvDMA.scala:31:24, :39:15, :56:{25,42}, :57:17]
endmodule