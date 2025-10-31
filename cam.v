`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KLE Technological University Hubli
// Engineer: Shivanand Honnappanavar
// 
// Create Date: 31.10.2025 20:10:39
// Design Name: 16 bit CAM
// Module Name: cam
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


//=====================================================================
// 16-bit Content Addressable Memory (CAM)
// Using explicit XNOR-based comparison logic
//=====================================================================



module cam16x16 (
    input  wire         clk,
    input  wire         rst_n,
    // Write interface
    input  wire         wr_en,
    input  wire  [3:0]  wr_addr,
    input  wire  [15:0] wr_data,
    // Search interface
    input  wire         search_en,
    input  wire  [15:0] search_data,
    // Outputs
    output wire         match,
    output wire [15:0]  match_onehot,
    output wire [3:0]   match_addr
);

    //-----------------------------------------------------------------
    // Parameters
    //-----------------------------------------------------------------
    localparam DATA_WIDTH = 16;
    localparam DEPTH      = 16;
    localparam ADDR_WIDTH = 4;

    //-----------------------------------------------------------------
    // Memory array
    //-----------------------------------------------------------------
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    integer i;

    //-----------------------------------------------------------------
    // Synchronous write operation
    //-----------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < DEPTH; i = i + 1)
                mem[i] <= {DATA_WIDTH{1'b0}};
        end else if (wr_en) begin
            mem[wr_addr] <= wr_data;
        end
    end

    //-----------------------------------------------------------------
    // XNOR-based comparison logic
    //-----------------------------------------------------------------
    reg [DEPTH-1:0] onehot_match_r;
    reg [DATA_WIDTH-1:0] xnor_result;

    always @(*) begin
        if (!search_en)
            onehot_match_r = {DEPTH{1'b0}};
        else begin
            for (i = 0; i < DEPTH; i = i + 1) begin
                // Bitwise XNOR and reduction AND
                xnor_result = ~(mem[i] ^ search_data);
                onehot_match_r[i] = &xnor_result;   // 1 if all bits match
            end
        end
    end

    //-----------------------------------------------------------------
    // Priority encoder for lowest-index match
    //-----------------------------------------------------------------
    reg [ADDR_WIDTH-1:0] match_addr_r;
    reg found;

    always @(*) begin
        match_addr_r = {ADDR_WIDTH{1'b0}};
        found = 1'b0;
        for (i = 0; i < DEPTH; i = i + 1) begin
            if (!found && onehot_match_r[i]) begin
                match_addr_r = i[ADDR_WIDTH-1:0];
                found = 1'b1;
            end
        end
    end

    //-----------------------------------------------------------------
    // Registered outputs (synchronous)
    //-----------------------------------------------------------------
    reg [DEPTH-1:0]  match_onehot_reg;
    reg [ADDR_WIDTH-1:0] match_addr_reg;
    reg match_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            match_onehot_reg <= 0;
            match_addr_reg   <= 0;
            match_reg        <= 0;
        end else if (search_en) begin
            match_onehot_reg <= onehot_match_r;
            match_addr_reg   <= match_addr_r;
            match_reg        <= |onehot_match_r;
        end
    end

    //-----------------------------------------------------------------
    // Output assignments
    //-----------------------------------------------------------------
    assign match_onehot = match_onehot_reg;
    assign match_addr   = match_addr_reg;
    assign match        = match_reg;

endmodule
