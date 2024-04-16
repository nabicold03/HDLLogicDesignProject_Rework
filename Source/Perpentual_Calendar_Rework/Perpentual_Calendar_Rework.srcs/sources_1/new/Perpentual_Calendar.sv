`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// University: Ho Chi Minh City University of Technology (Bach Khoa University) - Viet Nam National University, Ho Chi Minh City
// Engineer: Vu Nam Binh - Student.ID: 2152441
// 
// Create Date: 04/15/2024 03:06:45 PM
// Design Name: 
// Module Name: Perpentual_Calendar
// Project Name: HDL Logic Design Rework
// Target Devices: Arty - z7
// Tool Versions:  Vivado 2022
// Description: This is the project of HDL Logic Design Course that I took on the 2nd Semester of the 1st year
              //at HCMUT. However, due to lack of knowledge about HDL Verilog, there are many parts need improving.
              //That's the reason I rework this project, this is also a way for me to review and train my HDL skill.
              //Besides, in this rework version, I used SystemVerilog instead of Verilog in the original version 2 years ago.
              //Because, I do not have the FGPA Arty - z7 here, I will only do the synthesis and run simulation with a testbench.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Perpentual_Calendar(
    input wire clk, rst, option, change, //change is between displaying temporarily time/date, option is between displaying time/date permanently
    output reg [4:0] day, hour,
    output reg [3:0] month, 
    output reg [11:0] year, 
    output reg [5:0] minute, second
    );
    reg [2:0] count;
    reg leapyear;
    
    typedef enum reg [1:0]{Start=2'b00, Time24=2'b01, Time12=2'b11} para;
    typedef enum reg {AM=0, PM=1} time_type;
    
    para Current,Next;
    time_type AP;
    // assign Current = Time24;  //Default displaying mode is time in 24h
    
    
//--------------------------- Function to check leap year ---------------------------
    function automatic void process_leap(input [11:0] year, ref logic leap);
        if ( ((year%4==0) && (year%100!=0)) || (year%400==0) ) leap<=1;
    endfunction
//-----------------------------------------------------------------------------------



//--------------------------- Function to change time from Mode 24 to Mode 12 ---------------------------
    function automatic void change_time_to_12 (ref logic [4:0] hour, ref time_type AP);
        if (hour >= 12) begin
            hour <= hour - 12;
            if(hour == 12) AP = AM;
            else AP = PM;
        end
        else AP = AM;
    endfunction
//------------------------------------------------------------------------------------------------------- 



//--------------------------- Function to change time from Mode 12 to Mode 24 ---------------------------
    function automatic void change_time_to_24 (ref logic [4:0] hour, time_type AP);
        if(AP == PM) begin
            hour <= hour + 12;
        end
    endfunction
//-------------------------------------------------------------------------------------------------------



//--------------------------- Function to process output for state Time24 ---------------------------
    function automatic void process_Time24(ref logic [5:0] second,minute,
                                           ref logic [4:0] hour,day,
                                           ref logic [3:0] month,
                                           ref logic [11:0] year,
                                           ref logic leap_year);
        if(second == 59) begin
            second<=0;
            minute <= minute + 1;
        end
        else second <= second + 1;
                
        if(minute == 60) begin
            minute <= 0;
            hour <= hour + 1;
        end
                
        if(hour == 24) begin
            hour <= 0;
            day <= day + 1;
            process_Date(day,month,year,leap_year);
        end
    endfunction
//---------------------------------------------------------------------------------------------------


 
//--------------------------- Function to process output for Date ---------------------------
    function automatic void process_Date(
        ref logic [4:0] day,
        ref logic [3:0] month,
        ref logic [11:0] year,
        ref logic leap_year);
        process_leap(year,leap_year);
        case(month)
            1,3,5,7,8,10,12: begin
                if (day==32) begin
                    day <= 1;
                    month <= month + 1;
                end
            end
            4,6,9,11: begin
                if(day==31) begin
                    day <= 1;
                    month <= month + 1;
                end
            end
            2: begin
                if(leap_year) begin
                    if (day == 30) begin
                        day <= 1;
                        month <= month + 1;
                    end
                end
                else begin
                    if (day == 29) begin
                        day <= 1;
                        month <= month + 1;
                    end
                end
            end
            13: begin
                month <= 1;
                year <= year + 1;
            end
        endcase
    endfunction
//---------------------------------------------------------------------------------------------



//--------------------------- Function to process output for state Time12 ---------------------------
    function automatic void process_Time12 (
    ref logic [4:0] hour,day,
    ref logic [5:0] minute,second,
    ref time_type AP, 
    ref logic leap_year,
    ref logic [3:0] month,
    ref logic [11:0] year);
        if (second == 59) begin
            second <= 0;
            minute <= minute + 1;
        end
        else second <= second + 1;
        
        if(minute == 60) begin
            minute <= 0;
            hour <= hour + 1;
        end
        
        if(hour == 12) begin
            hour <= 0;
            if(AP == AM) AP = PM;
            else begin
                AP = AM;
                process_Date(day,month,year,leap_year);
            end
        end
    endfunction
//---------------------------------------------------------------------------------------------------
    


// FINITE STATE MACHINE
//+++++++++++++++++++++++++++  Combinational Block to process next state +++++++++++++++++++++++++++
    always_comb begin
        case(Current)
            Start: begin
                Next = Time24;
            end
            Time24: begin
                if(option == 1) begin
                    Next = Time12;
                end
                else Next = Time24;
            end
            Time12: begin
                if(option == 1) begin
                    Next = Time24;
                end
                else Next=Time12;
            end
            default: Next=Start;
        endcase
    end
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    
    
//+++++++++++++++++++++++++++ D Flip Flop Sequential Block +++++++++++++++++++++++++++
    always_ff @(posedge clk, negedge rst) begin
        if(~rst) Current <= Start;
        else begin
            //if change Displaying mode 
            if (option == 1) begin
                if(Current == Time24) Current <= Time12;
                else if (Current == Time12) Current <= Time24;
            end
            else Current <= Next;
        end
    end
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



//+++++++++++++++++++++++++++ Process Output +++++++++++++++++++++++++++
    always_ff @(posedge clk, negedge rst) begin
        if (~rst) begin
            second <= 30;
            minute <= 59;
            hour <= 23;
            day <= 30;
            month <= 4;
            year <= 2024;
        end
        else begin
            case(Current)
                Start: begin
                    count <= 0;
                end
                Time24: begin 
                    process_Time24(second,minute,hour,day,month,year,leapyear);
                    if(option == 1) begin
                        change_time_to_12(hour,AP);
                    end
                end
                
                Time12: begin
                    process_Time12(hour,day,minute,second,AP,leapyear,month,year);
                    if(option == 1) begin
                        change_time_to_24(hour,AP);
                    end
                end            
            endcase
        end
    end
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
endmodule
