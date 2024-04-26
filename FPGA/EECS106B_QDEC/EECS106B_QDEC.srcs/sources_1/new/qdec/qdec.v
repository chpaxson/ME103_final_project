module qdec (
    input clk,
    input reset,

    input A,
    input B,
    output [63:0] count
);

wire A_prev, B_prev;
wire A_rise, B_rise, A_fall, B_fall; 
wire [63:0] count_next, count;

assign A_rise = ~A_prev && A;
assign A_fall = A_prev && ~A;
assign B_rise = ~B_prev && B;
assign B_fall = B_prev && ~B;

assign count_next = A_rise? ( B ? (count - 1'b1) : (count + 1'b1) ):
                    A_fall? ( B ? (count + 1'b1) : (count - 1'b1) ):
                    B_rise? ( A ? (count + 1'b1) : (count - 1'b1) ):
                    B_fall? ( A ? (count - 1'b1) : (count + 1'b1) ):
                    count;





REGISTER_R #(.N(1), .INIT(0)) A_register (
    .q(A_prev), .d(A),
    .rst(reset), .clk(clk)
);

REGISTER_R #(.N(1), .INIT(0)) B_register (
    .q(B_prev), .d(B),
    .rst(reset), .clk(clk)
);

REGISTER_R #(.N(64), .INIT(64'b0)) counter (
    .q(count), .d(count_next),
    .rst(reset), .clk(clk)
);


endmodule