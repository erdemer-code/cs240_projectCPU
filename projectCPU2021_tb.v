`timescale 1ns / 1ps

// This tb accompanies projectCPU2021_test.asm. Since that program is obtained by porting
// a VSCPU asm program to projectCPU, the memCheck functions below are based on
// VSCPU instructions.

// YOU SHOULD SUCCESSFULLY PASS:
// SIMULATION AND SYNTHESIS

module projectCPU_tb;

reg clk;
initial begin
  clk = 1;
  forever
    #5 clk = ~clk;
end

integer ff;
reg rst;
initial begin
  ff = $fopen("outputLog.txt", "w");
  // $dumpvars;
  rst = 1;
  repeat (10) @(posedge clk);
  rst <= #1 0;
  repeat (1000) @(posedge clk);
  repeat (1000) begin
    @(posedge clk);
    if (instrCount == 159) begin
      PCCheck(158, "JMP Indirect Test"); 
      $fwrite(ff, "Total Errors = %d\n", errorCount);
      $display("Total Errors = %d", errorCount);
      if (errorCount == 0) begin
        $fwrite(ff, "Simulation Successfully Completed\n");
        $display("Simulation Successfully Completed");
		  $fclose(ff);
        $finish;
      end
      $fwrite(ff, "Simulation Failed\n");
      $display("Simulation Failed");
      $fclose(ff); 
      $finish;
    end
  end
  $fwrite(ff, "Simulation finished due to Time Limit.\nTest Count = %d\nTotal Errors = %d\n", instrCount, errorCount);
  $display("Simulation finished due to Time Limit.\nTest Count = %d\nTotal Errors = %d\n", instrCount, errorCount);
  $fclose(ff);
  $finish;
end

wire [12:0] addr_toRAM;
wire [15:0] data_toRAM, data_fromRAM;
wire [12:0] PC;
wire [15:0] W;

projectCPU2021 projectCPU(
  .clk(clk),
  .rst(rst),
  .wrEn(wrEn),
  .data_fromRAM(data_fromRAM),
  .addr_toRAM(addr_toRAM),
  .data_toRAM(data_toRAM),
  .PC(PC), // Added as an output for TB purposes
  .W(W) // Added as an output for TB purposes
);

blram blram(
  .clk(clk),
  .rst(rst),
  .i_we(wrEn),
  .i_addr(addr_toRAM),
  .i_ram_data_in(data_toRAM),
  .o_ram_data_out(data_fromRAM)
);

reg [8:0] instrCount = 0;
reg [8:0] errorCount = 0;

always @(PC) begin
  case(instrCount -1)
    0: PCCheck(3, "JMP Test");
    8: WCheck(32, "ADD Test 0");
    14: WCheck(16, "ADD Test 1");
    20: WCheck(0, "NAND Test 0");
    26: WCheck(16'h00F7, "NAND Test 1");
    32: WCheck(8, "SRRL Test 0");
    38: WCheck(128, "SRRL Test 1");
    44: WCheck(16'hDF00, "SRRL Test 2");
    50: WCheck(16'hEEFB, "SRRL Test 3");
    56: WCheck(0, "GE Test 0");
    62: WCheck(1, "GE Test 1");
    68: WCheck(1, "GE Test 0");
    74: memCheck(72, 255, "CP2W and CPfW Test");
    78: PCCheck(80, "SZ Test 0");
    84: PCCheck(85, "SZ Test 1");
    97: WCheck(16, "ADD Indirect Test");
    106: WCheck(16'hFF0F, "NAND Indirect Test");
    115: WCheck(16'hDEC0, "SRRL Indirect Test");
    124: WCheck(1, "GE Indirect Test");
    131: PCCheck(133, "SZ Indirect Test");
    142: WCheck(16'hFEED, "CP2W Indirect Test");
    151: memCheck(147, 16'hDEAF, "CPfW Indirect Test");
    158: begin
      PCCheck(158, "JMP Indirect Test"); 
      $fwrite(ff, "Total Errors = %d\n", errorCount);
      $fclose(ff); 
      $finish;
    end
  endcase

  instrCount = PC + 1;

end

task memCheck;
input [12:0] memLocation;
input [15:0] expectedValue;
input [143:0] instMnemonic; 
begin
  if(blram.memory[memLocation] !== expectedValue) begin
    $fwrite(
      ff,"Error Found at instrCount %d, Test: %s, %d ns, RAM Addr %d: expected %d, received %d\n",
      instrCount -1, instMnemonic, $time, memLocation, expectedValue, blram.memory[memLocation]
    );
    $display(
      "Error Found at instrCount %d, Test: %s, %d ns, RAM Addr %d: expected %h, received %h\n",
    instrCount -1, instMnemonic, $time, memLocation, expectedValue, blram.memory[memLocation]
    );
    errorCount = errorCount +1;
  end else begin
    $fwrite(
      ff,"Memory correct at instrCount %d, Test: %s, %d ns, RAM Addr %d: expected %d, received %d\n",
      instrCount -1, instMnemonic, $time, memLocation, expectedValue, blram.memory[memLocation]
    );
    $display(
      "Memory correct at instrCount %d, Test: %s, %d ns, RAM Addr %d: expected %h, received %h\n",
    instrCount -1, instMnemonic, $time, memLocation, expectedValue, blram.memory[memLocation]
    );
  end
end
endtask

task PCCheck;
input [31:0] PCExpected;
input [143:0] instMnemonic;
begin
  if(PC !== PCExpected) begin
    $fwrite(
      ff,"Error Found at instrCount %d, Test: %s, %d ns: expected PC=%d, observed PC=%d\n",
      instrCount -1, instMnemonic, $time, PCExpected, PC
    );
    $display(
      "Error Found at instrCount %d, Test: %s, %d ns: expected PC=%d, observed PC=%d\n",
      instrCount -1, instMnemonic, $time, PCExpected, PC
    );
    errorCount = errorCount + 1;
  end else begin
    $fwrite(
      ff,"PC correct at instrCount %d, Test: %s, %d ns: expected PC=%d, observed PC=%d\n",
      instrCount -1, instMnemonic, $time, PCExpected, PC
    );
    $display(
      "PC correct at instrCount %d, Test: %s, %d ns: expected PC=%d, observed PC=%d\n",
      instrCount -1, instMnemonic, $time, PCExpected, PC
    );
  end
end
endtask

task WCheck;
input [15:0] expectedValue;
input [143:0] instMnemonic;
begin
  if(W !== expectedValue) begin
    $fwrite(
      ff,"Error Found at instrCount %d, Test: %s, %d ns: expected W=%d, observed W=%d\n",
      instrCount -1, instMnemonic, $time, expectedValue, W
    );
    $display(
      "Error Found at instrCount %d, Test: %s, %d ns: expected W=%h, observed W=%h\n",
      instrCount -1, instMnemonic, $time, expectedValue, W
    );
    errorCount = errorCount + 1;
  end else begin
    $fwrite(
      ff,"W correct at instrCount %d, Test: %s, %d ns: expected W=%d, observed W=%d\n",
      instrCount -1, instMnemonic, $time, expectedValue, W
    );
    $display(
      "W correct at instrCount %d, Test: %s, %d ns: expected W=%h, observed W=%h\n",
      instrCount -1, instMnemonic, $time, expectedValue, W
    );
  end
end
endtask

endmodule
