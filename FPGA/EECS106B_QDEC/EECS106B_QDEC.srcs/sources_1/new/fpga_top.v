`timescale 1ns / 1ps

module fpga_top #(
    parameter BAUD_RATE = 921600
) (
    input CLK,
    input [1:0] BTN,
    output [1:0] LED,
    output [2:0] RGB,

    // QDEC Terminals
    input [14:0] IO_A,
    input [14:0] IO_B,

    // UARt Terminals
    output STM32_OUT,
    input STM32_IN,
    output UART_TXD,
    input UART_RXD
);

// +------------------------------------------------------------+
// | Use clock PLL to set Frequency to 125 MHz
// +------------------------------------------------------------+
wire CLK_125MHZ;
clk_wiz_0 clk_pll(.reset(0'b0), .clk_in1(CLK), .clk_out1(CLK_125MHZ));

// +------------------------------------------------------------+
// | Synchronize values
// +------------------------------------------------------------+

wire [14:0] A_qdec, B_qdec;
synchronizer # (
    .WIDTH(15)
) input_synchronizer_A (
    .clk(CLK_125MHZ),
    .async_signal(IO_A),
    .sync_signal(A_qdec)
);

synchronizer # (
    .WIDTH(15)
) input_synchronizer_B (
    .clk(CLK_125MHZ),
    .async_signal(IO_B),
    .sync_signal(B_qdec)
);

wire [1:0] BTN_sync;
synchronizer # (
    .WIDTH(2)
) input_synchronizer_BTN (
    .clk(CLK_125MHZ),
    .async_signal(BTN),
    .sync_signal(BTN_sync)
);

// +------------------------------------------------------------+
// | Declare Wires
// +------------------------------------------------------------+

// declare relevant wires
wire queue_rst;

wire STM_send_ready, STM_send_valid;
wire[7:0] STM_data, STM_send;

wire STM_recv_ready, STM_recv_valid;

wire USB_ready, USB_valid;


// declare QDEC wires
wire qdec_rst;
wire[63:0] count_0, count_1, count_2, count_3, count_4, count_5, count_6, count_7, count_8, count_9, count_10, count_11, count_12, count_13, count_14;

// set LED values
assign LED[0] = count_0[8]; //(STM32_data == 8'b01100001);
assign LED[1] = (STM_data == 8'b01100001); //count_1[8]; //A_qdec[0] == 1'b1;

assign RGB[0] = ~A_qdec[0];
assign RGB[1] = 1'b1; //~B_qdec[0];
assign RGB[2] = ~BTN_sync[0];

assign queue_rst = 1'b0;
assign qdec_rst = BTN_sync[0] || ((STM_data == 8'b01000001) && STM_recv_valid);

// +------------------------------------------------------------+
// | Declare any QDEC modules
// +------------------------------------------------------------+

qdec QDEC_0(
    .clk(CLK_125MHZ), .reset(qdec_rst), 
    .A(A_qdec[0]), .B(B_qdec[0]), .count(count_0)
);

qdec QDEC_1(
    .clk(CLK_125MHZ), .reset(qdec_rst), 
    .A(A_qdec[1]), .B(B_qdec[1]), .count(count_1)
);

qdec QDEC_2(
    .clk(CLK_125MHZ), .reset(qdec_rst), 
    .A(A_qdec[2]), .B(B_qdec[2]), .count(count_2)
);

qdec QDEC_3(
    .clk(CLK_125MHZ), .reset(qdec_rst), 
    .A(A_qdec[3]), .B(B_qdec[3]), .count(count_3)
);

qdec QDEC_4(
    .clk(CLK_125MHZ), .reset(qdec_rst), 
    .A(A_qdec[4]), .B(B_qdec[4]), .count(count_4)
);

qdec QDEC_5(
    .clk(CLK_125MHZ), .reset(qdec_rst), 
    .A(A_qdec[5]), .B(B_qdec[5]), .count(count_5)
);

qdec QDEC_6(
    .clk(CLK_125MHZ), .reset(qdec_rst), 
    .A(A_qdec[6]), .B(B_qdec[6]), .count(count_6)
);

qdec QDEC_7(
    .clk(CLK_125MHZ), .reset(qdec_rst), 
    .A(A_qdec[7]), .B(B_qdec[7]), .count(count_7)
);

qdec QDEC_8(
    .clk(CLK_125MHZ), .reset(qdec_rst), 
    .A(A_qdec[8]), .B(B_qdec[8]), .count(count_8)
);



qdec QDEC_U0(
    .clk(CLK_125MHZ), .reset(qdec_rst), 
    .A(A_qdec[9]), .B(B_qdec[9]), .count(count_9)
);
qdec QDEC_U1(
    .clk(CLK_125MHZ), .reset(qdec_rst), 
    .A(A_qdec[10]), .B(B_qdec[10]), .count(count_10)
);
qdec QDEC_U2(
    .clk(CLK_125MHZ), .reset(qdec_rst), 
    .A(A_qdec[11]), .B(B_qdec[11]), .count(count_11)
);
qdec QDEC_U3(
    .clk(CLK_125MHZ), .reset(qdec_rst), 
    .A(A_qdec[12]), .B(B_qdec[12]), .count(count_12)
);
qdec QDEC_U4(
    .clk(CLK_125MHZ), .reset(qdec_rst), 
    .A(A_qdec[13]), .B(B_qdec[13]), .count(count_13)
);
qdec QDEC_U5(
    .clk(CLK_125MHZ), .reset(qdec_rst), 
    .A(A_qdec[14]), .B(B_qdec[14]), .count(count_14)
);


// +------------------------------------------------------------+
// | UART Control logic
// +------------------------------------------------------------+
wire[63:0] fifo_enqdata, fifo_enqdata_sync;
// assign fifo_enqdata =   (STM_data == 8'b01100001)? count_0 :
//                         (STM_data == 8'b01100010)? count_1 :
//                         (STM_data == 8'b01100011)? count_2 :
//                         (STM_data == 8'b01100100)? count_3 :
//                         (STM_data == 8'b01100101)? count_4 :
//                         (STM_data == 8'b01100110)? count_5 :
//                         (STM_data == 8'b01100111)? count_6 :
//                         (STM_data == 8'b01101000)? count_7 :
//                         (STM_data == 8'b01101001)? count_8 :
//                         (STM_data == 8'b01101010)? count_9 :
//                         (STM_data == 8'b01101011)? count_10 :
//                         (STM_data == 8'b01101100)? count_11 :
//                         (STM_data == 8'b01101101)? count_12 :
//                         (STM_data == 8'b01101110)? count_13 :
//                         (STM_data == 8'b01101111)? count_14 : 64'b0;

assign fifo_enqdata =   (STM_data == 8'b01100001)? count_0 :
                        (STM_data == 8'b01100010)? count_1 :
                        (STM_data == 8'b01100011)? count_2 :
                        (STM_data == 8'b01100100)? count_3 :
                        (STM_data == 8'b01100101)? count_4 :
                        (STM_data == 8'b01100110)? count_5 :
                        (STM_data == 8'b01100111)? count_6 :
                        (STM_data == 8'b01101000)? count_7 :
                        (STM_data == 8'b01101001)? count_8 :
                        (STM_data == 8'b01101010)? count_9 :
                        (STM_data == 8'b01101011)? count_10 :
                        (STM_data == 8'b01101100)? count_11 :
                        (STM_data == 8'b01101101)? count_12 :
                        (STM_data == 8'b01101110)? count_13 :
                        (STM_data == 8'b01101111)? count_14 : 64'b0;


wire [3:0] mw_count;
wire queueStore;

REGISTER #(.N(1)) enqueue_sync (
    .q(queueStore), .d(STM_recv_valid),
    .clk(CLK_125MHZ)
);

REGISTER #(.N(64)) enqueue_bits_sync (
    .q(fifo_enqdata_sync), .d(fifo_enqdata),
    .clk(CLK_125MHZ)
);

// MixedWidthQueue UART_queue(
//     .clock(CLK_125MHZ), .reset(1'b0), 

//     .io_enq_ready(), 
//     .io_enq_valid(queueStore), 
//     .io_enq_bits(fifo_enqdata_sync), 

//     .io_deq_ready(STM_send_ready), 
//     .io_deq_valid(STM_send_valid), 
//     .io_deq_bits(STM_send),

//     .io_count(mw_count)
// );

wire[63:0] fifo_wire;
wire fifo_valid, fifo_ready;

Queue UART_FIFO(
    .clock(CLK_125MHZ), .reset(1'b0), 

    .io_enq_ready(/*unused*/), 
    .io_enq_valid(queueStore), 
    .io_enq_bits(fifo_enqdata_sync), 

    .io_deq_ready(fifo_ready), 
    .io_deq_valid(fifo_valid), 
    .io_deq_bits(fifo_wire), 

    .io_count(/*unused*/)
);


VectorToSingle serializer(
    .clock(CLK_125MHZ), .reset(1'b0), 

    .io_in_ready(fifo_ready), 
    .io_in_valid(fifo_valid), 
    .io_in_bits(fifo_wire), 

    .io_out_ready(STM_send_ready), 
    .io_out_valid(STM_send_valid), 
    .io_out_bits(STM_send)

);

// +------------------------------------------------------------+
// | Pipe UART data from USB port
// +------------------------------------------------------------+
uart #(
    .CLOCK_FREQ(125_000_000),
    .BAUD_RATE(921600)
) USB_uart (
    .clk(CLK_125MHZ), .reset(1'b0),

    // send to USB (TX)
    .data_in((mw_count >= 1'b1)? 8'b01100011 : 8'b01100001),
    .data_in_valid(STM_recv_valid),
    .data_in_ready(),

    // reat from USB (RX)
    .data_out(),
    .data_out_valid(),
    .data_out_ready(1'b0),

    .serial_in(UART_RXD),
    .serial_out(UART_TXD)
);


// +------------------------------------------------------------+
// | Pipe UART data from STM32
// +------------------------------------------------------------+

uart #(
    .CLOCK_FREQ(125_000_000),
    .BAUD_RATE(921600) //1843200
    // .BAUD_RATE(115200)
) STM_uart (
    .clk(CLK_125MHZ), .reset(1'b0),

    // Send to STM32 (TX)
    .data_in(STM_send),
    // .data_in(8'b01100101),
    .data_in_valid(STM_send_valid),
    .data_in_ready(STM_send_ready),

    // Read from STM32 (RX)
    .data_out(STM_data),
    .data_out_valid(STM_recv_valid),
    .data_out_ready(1'b1),

    .serial_in(STM32_IN),
    .serial_out(STM32_OUT)
);

endmodule