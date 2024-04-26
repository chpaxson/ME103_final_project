module synchronizer #(parameter WIDTH = 1) (
    input [WIDTH-1:0] async_signal,
    input clk,
    output [WIDTH-1:0] sync_signal
);
	wire [WIDTH-1:0] intermediate;	

	REGISTER #(.N(WIDTH)) first_R (.q(intermediate), .d(async_signal), .clk(clk));
	REGISTER #(.N(WIDTH)) second_R (.q(sync_signal), .d(intermediate), .clk(clk)); 
endmodule
