//////////////////////////////////////////////////////////////////////
// Author       : omerorkn
// Date         : 27.05.2023
// Revision     : 00
// Description  : This module tests square root calculations
// -- History --
// Rev. 00      : File created. (27.05.2023)
//////////////////////////////////////////////////////////////////////

`default_nettype none
`timescale 1ns / 1ps

module tb_square_root();

    parameter CLK_PERIOD    = 10;                                       // clock period for clock generation
    parameter WIDTH         = 48;                                       // radicand bit width
    parameter F_BITS        = 28;                                       // fractional bit width
    parameter SF            = 2.0**-28.0;                               // Q20.28 scaling factor is 2^-28

    logic clk;                                                          // clock signal
    logic rst_n;                                                        // active low reset signal
    logic enable;                                                       // enable signal
    logic busy;                                                         // calculation in progress
    logic valid;                                                        // root and rem are valid
    logic [WIDTH-1:0] radicand;                                         // radicand
    logic [WIDTH-1:0] sq_root;                                          // square root
    logic [WIDTH-1:0] remainder;                                        // remainder

    square_root #(.WIDTH(WIDTH), .F_BITS(F_BITS)) square_root_inst (.*);

    always #(CLK_PERIOD / 2) clk = ~clk;

    initial 
    begin
        $monitor("\t%d:\tsqrt(%f) = %b (%f) (rem = %b) (V=%b)",         // for fixed point numbers
                $time, $itor(radicand * SF), sq_root, $itor(sq_root * SF), remainder, valid);
                
//        $monitor("\t%d:\tsqrt(%d) = (%d) (rem = %d) (V=%b)",          // for integer numbers
//                $time, radicand, sq_root, remainder, valid);
    end

    initial
    begin
        clk         = 1;
        rst_n       = 1;
        enable      = 0;
        radicand    = 0;
        #100
        rst_n   = 0;
        #50
        rst_n   = 1;
        #50
        radicand = 48'b1111_1100_1010_1111_1000_1001_0000_0000_0000_0000_0000_0000; // 1035000.5625
        //radicand = 16'b1110_1000_1001_0000;  // 232.56250000
        //radicand = 16'b0000_0000_0100_0000;   // 64
        enable = 1;
        #390
        radicand = 48'b0000_0000_1010_1111_1000_1001_0000_0000_0000_0000_0000_0000; //2808.5625
        //radicand = 16'b0000_0000_0100_0000;  // 0.25
        //radicand = 16'b0000_0000_0000_0100;     // 4
        #390
        radicand = 48'b0000_1010_1010_0000_1000_1101_0000_0000_0000_0000_0000_0000; // 43528.8125
        //radicand = 16'b0000_0010_0000_0000;   // 2.0
        //radicand = 16'b0000_0000_0101_0001;     // 81
        #450
        enable = 0;
        $finish;
    end

endmodule