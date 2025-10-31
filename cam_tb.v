`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KLE Technolgical University Hubli
// Engineer: shivanand Honnappanavar
// 
// Create Date: 31.10.2025 20:11:19
// Design Name: !6 bit CAM testbench
// Module Name: cam_tb
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
/////////////////////////////////////////////////////////////////////////////////

module tb_cam16x16;

    // ------------------------------------------------------------------
    // DUT Interface
    // ------------------------------------------------------------------
    reg         clk;
    reg         rst_n;
    reg         wr_en;
    reg  [3:0]  wr_addr;
    reg  [15:0] wr_data;
    reg         search_en;
    reg  [15:0] search_data;
    wire        match;
    wire [15:0] match_onehot;
    wire [3:0]  match_addr;

    // ------------------------------------------------------------------
    // Instantiate the CAM
    // ------------------------------------------------------------------
    cam16x16 uut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .search_en(search_en),
        .search_data(search_data),
        .match(match),
        .match_onehot(match_onehot),
        .match_addr(match_addr)
    );

    // ------------------------------------------------------------------
    // Clock generation
    // ------------------------------------------------------------------
    always #5 clk = ~clk;  // 100 MHz clock (period = 10ns)

    // ------------------------------------------------------------------
    // Test procedure
    // ------------------------------------------------------------------
    initial begin
        // Initialize
        clk = 0;
        rst_n = 0;
        wr_en = 0;
        wr_addr = 0;
        wr_data = 0;
        search_en = 0;
        search_data = 0;

        // Reset
        $display("---- Resetting CAM ----");
        #20;
        rst_n = 1;

        // ------------------------------------------------------------------
        // Write data into CAM
        // ------------------------------------------------------------------
        $display("\n---- Writing data to CAM ----");
        write_cam(0, 16'h1234);
        write_cam(1, 16'h5678);
        write_cam(2, 16'h9abc);
        write_cam(3, 16'hdef0);
        write_cam(4, 16'h0000);
        write_cam(5, 16'h9abc);
        write_cam(6, 16'hffff);
        write_cam(7, 16'h0001);
        
        // ------------------------------------------------------------------
        // Search for existing data
        // ------------------------------------------------------------------
        $display("\n---- Searching for 16'h9ABC ----");
        search_cam(16'h9abc);

        // ------------------------------------------------------------------
        // Search for data not present
        // ------------------------------------------------------------------
        $display("\n---- Searching for 16'hFFFF ----");
        search_cam(16'h0011);

      
        $display("\n---- Searching for 16'h1234 ----");
        search_cam(16'h1234);

        // ------------------------------------------------------------------
        // End simulation
        // ------------------------------------------------------------------
        #50;
        $display("\n---- Simulation Complete ----");
        $finish;
    end

    // ------------------------------------------------------------------
    // Task: Write to CAM
    // ------------------------------------------------------------------
    task write_cam(input [3:0] addr, input [15:0] data);
    begin
        @(negedge clk);
        wr_en = 1;
        wr_addr = addr;
        wr_data = data;
        @(negedge clk);
        wr_en = 0;
        $display("Write: Addr=%0d Data=0x%h", addr, data);
    end
    endtask

    // ------------------------------------------------------------------
    // Task: Search CAM
    // ------------------------------------------------------------------
    task search_cam(input [15:0] data);
    begin
        @(negedge clk);
        search_en = 1;
        search_data = data;
        @(posedge clk); // wait for registered output
        #1; // small delay to allow update
        if (match)
            $display("Match FOUND: Data=0x%h | Addr=%0d | Onehot=%b",
                      data, match_addr, match_onehot);
        else
            $display("No match FOUND | Data (0x%h) not in CAM", data);
        @(negedge clk);
        search_en = 0;
    end
    endtask

endmodule