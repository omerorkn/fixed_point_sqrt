///////////////////////////////////////////////////////////////////////
// Author           : omerorkn
// Creation Date    : 26.05.2023
// Revision         : 02
// Description      : This module calculates square root value
// -- History --
// Rev. 00          : File created. (26.05.2023)
// Rev. 01          : Fixed-point option added to design. (27.05.2023)
// Rev. 02          : Comments added to code. (27.05.2023)
///////////////////////////////////////////////////////////////////////

`default_nettype none
`timescale 1ns / 1ps

module square_root
    #(
        parameter WIDTH     = 48,                               // radicand bit width (total)
        parameter F_BITS    = 28                                // fractional bits (for fixed point), you can use '0' for only integers
    ) 
    (
        // Input Ports
        input wire logic clk,                                   // clock source
        input wire logic rst_n,                                 // active low reset
        input wire logic enable,                                // module enable
        input wire logic [WIDTH - 1 : 0] radicand,              // the number you want to calculate the square root of

        // Ouput Ports
        output logic busy,                                      // calculation in progress
        output logic valid,                                     // valid flag for root and remainder
        output logic [WIDTH - 1 : 0] sq_root,                   // square root value
        output logic [WIDTH - 1 : 0] remainder                  // remainder
    );

    localparam ITERATION_LIMIT = (WIDTH + F_BITS) >> 1;         // Iterations are half (radicand+fbits) width

    logic [WIDTH - 1 : 0] x_prev, x;                            // radicand copy
    logic [WIDTH - 1 : 0] q_prev, q;                            // intermediate root (quotient)
    logic [WIDTH + 1 : 0] acc_reg_prev, acc_reg;                // accumulator register (2 bits wider)
    logic [WIDTH + 1 : 0] sign_test_reg;                        // sign test result (2 bits wider)
    logic [$clog2(ITERATION_LIMIT) - 1 :0] i;                   // Iteration counter

    always_comb
    begin
        sign_test_reg = acc_reg_prev - {q_prev, 2'b01};
        if (sign_test_reg[WIDTH + 1] == 0)
        begin
            {acc_reg, x} = {sign_test_reg[WIDTH - 1 : 0], x_prev, 2'b0};
            q = {q_prev[WIDTH - 2 : 0], 1'b1};
        end
        else
        begin
            {acc_reg, x} = {acc_reg_prev[WIDTH - 1 : 0], x_prev, 2'b0};
            q = q_prev << 1;
        end
    end

    always_ff @(posedge clk or negedge rst_n)
    begin

        if (rst_n == 1'b0)
        begin
            busy            <= 0;
            valid           <= 0;
            i               <= 0;
            q_prev          <= 0;
            remainder       <= 0;
            acc_reg_prev    <= 0;
            x_prev          <= 0;
            sq_root         <= 0;
        end
        else
        begin
            if (enable == 1'b1)
            begin
                if (busy)
                begin
                    if (i == ITERATION_LIMIT - 1)
                    begin
                        busy        <= 0;
                        valid       <= 1;
                        i           <= 0;
                        sq_root     <= q;
                        remainder   <= acc_reg[WIDTH + 1 : 2];
                    end
                    else
                    begin
                        i               <= i + 1;
                        x_prev          <= x;
                        valid           <= 0;
                        acc_reg_prev    <= acc_reg;
                        q_prev          <= q;
                    end
                end
                else
                begin
                    busy                    <= 1;
                    valid                   <= 0;
                    q_prev                  <= 0;
                    {acc_reg_prev, x_prev}  <= {{WIDTH{1'b0}}, radicand, 2'b0};
                end
            end
            else
            begin
                busy            <= 0;
                valid           <= 0;
                q_prev          <= 0;
                i               <= 0;
                sq_root         <= 0;
                remainder       <= 0;
                acc_reg_prev    <= 0;
                x_prev          <= 0;
            end
        end
    end
endmodule