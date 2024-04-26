module edge_detector #(
    parameter WIDTH = 1
)(
    input clk,
    input [WIDTH-1:0] signal_in,
    output [WIDTH-1:0] edge_detect_pulse
);
	wire [WIDTH-1:0] delayed;
    REGISTER #(.N(WIDTH)) detector (.q(delayed), .d(signal_in), .clk(clk));

	assign edge_detect_pulse = ~signal_in & delayed;
endmodule
