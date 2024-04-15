`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2024 07:38:48 PM
// Design Name: 
// Module Name: Perpentual_Calendar_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Perpentual_Calendar_tb;
logic clk, rst, option, change;
reg [5:0] second, minute;
reg [4:0] hour,day;
reg [3:0] month;
reg [11:0] year;
typedef enum {AM=0, PM=1} time_type;
time_type AP;
Perpentual_Calendar dut(.clk(clk),.rst(rst),.option(option),.change(change),.second(second),.minute(minute),.hour(hour),.day(day),.month(month),.year(year));

initial begin
    clk=1'b0;
    forever #5 clk = ~clk;
end

initial begin
    #0 rst=0;
    #1 rst=1;
    #100 option=1;
    #10 option=0;
    #5000 $finish;
end

always_ff @(posedge clk) begin
    $display("%d/%d/%d - %d:%d:%d - %d - State: %d - Option: %d",day,month,year,hour,minute,second,AP,dut.Current,option);
end

endmodule
