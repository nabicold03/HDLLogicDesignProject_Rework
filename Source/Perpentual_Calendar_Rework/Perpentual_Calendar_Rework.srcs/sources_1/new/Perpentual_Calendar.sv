`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2024 03:06:45 PM
// Design Name: 
// Module Name: Perpentual_Calendar
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


module Perpentual_Calendar(
    input clk, rst, option, change, //change is between displaying temporarily time/date, option is between displaying time/date permanently
    output day, month, year, hour, minute, second
    );
    wire clk,rst,option,change;
    reg [4:0] day;
    reg [3:0] month;
    reg [11:0] year;
    reg [5:0] minute,second;
    reg [2:0] count;
    
    typedef enum reg [1:0]{Start=2'b00, Time24=2'b01, Date=2'b11, Time12=2'b10} para;
    
    para Current,Next;
    assign Current=Time24;  //Default displaying mode is time in 24h
    
    always_comb begin
        case(Current)
            Start: begin
                count = 0;
                Next=Time24;
            end
            Time24: begin
                if(option==1) begin
                    Next=Time12;
                end
                else if(change==1) begin
                    Next=Date;
                end
                else Next=Time24;
            end
            Date: begin
                if(option==1) begin
                    Next=Time12;
                end
                else if(count <= 0) begin
                    Next=Time24;
                end
                else Next=Date;
            end
            Time12: begin
                if(option==0) begin
                    Next=Time24;
                end
                else if(change==1) begin
                    Next=Date;
                end
                else Next=Time12;
            end
        endcase
    end
    
    always_ff @(posedge clk, negedge rst) begin
        if(!rst) begin
            Current <= Start;
        end
        else begin
            Current <= Next;
        end
    end
    
endmodule
