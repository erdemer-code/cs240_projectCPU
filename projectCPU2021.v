module projectCPU2021(
  clk,
  rst,
  wrEn,
  data_fromRAM,
  addr_toRAM,
  data_toRAM,
  PC,
  W
);

input clk, rst;

input wire [15:0] data_fromRAM;
output reg [15:0] data_toRAM;
output reg wrEn;

// 12 can be made smaller so that it fits in the FPGA
output reg [12:0] addr_toRAM;
output reg [12:0] PC; // This has been added as an output for TB purposes
output reg [15:0] W; // This has been added as an output for TB purposes

// Your design goes in here
reg [12:0] PCNext;
reg [15:0] WNext;
reg [ 2:0] opcode, opcodeNext;
reg [12:0] operand1, operand1Next;
reg [15:0] num1, num1Next;
reg [ 2:0] state, stateNext;

always @(posedge clk) begin
  state    <= #1 stateNext;
  PC       <= #1 PCNext; 
  opcode   <= #1 opcodeNext;
  operand1 <= #1 operand1Next;
  num1     <= #1 num1Next;
  W        <= #1 WNext;
end

always @* begin
  stateNext    = state;
  PCNext       = PC;
  opcodeNext   = opcode;
  operand1Next = operand1;
  num1Next     = num1;
  WNext        = W;
  addr_toRAM   = 0;
  wrEn         = 0;
  data_toRAM   = 0;
  if (rst) begin
    stateNext    = 0;
    PCNext       = 0;
    opcodeNext   = 0;
    operand1Next = 0;
    num1Next     = 0;
    WNext        = 0;
    addr_toRAM   = 0;
    wrEn         = 0;
    data_toRAM   = 0;
  end else
    case (state)
      0: begin         // "addr_toRAM = pCounter" => read memory location of pCounter
        PCNext = PC;
        opcodeNext   = opcode;
        operand1Next = 0;
        addr_toRAM   = PC;
        num1Next     = 0;
        wrEn         = 0;
        data_toRAM   = 0;
        stateNext    = 1;
      end
      1: begin // take opcode and request *A
        PCNext       = PC;
        opcodeNext   = data_fromRAM[15:13];
        operand1Next = data_fromRAM[12:0];
        addr_toRAM   = data_fromRAM[12:0];
        num1Next     = 0;
        WNext        = W;
        wrEn         = 0;
        data_toRAM   = 0;
        stateNext    = 2;
      end
      2: begin // take *A
        PCNext       = PC; 
        opcodeNext   = opcode;
        operand1Next = operand1;
        addr_toRAM   = operand1;
        num1Next     = data_fromRAM;
        WNext        = W;
        wrEn         = 0;
        data_toRAM   = 0;
        if(operand1 == 0) begin // indirect
          addr_toRAM = 2;
          stateNext  = 5;
        end 
        else if(opcode == 3'b100 || opcode == 3'b111) // SZ or JMP
          stateNext = 4;
        else
          stateNext = 3;
      end
      3: begin
        PCNext       = PC + 1;
        opcodeNext   = opcode;
        operand1Next = operand1;
        num1Next     = num1;
        WNext        = W;
        addr_toRAM   = W;
        wrEn         = 0;
        if(opcode == 3'b000) // ADD
          WNext = W + num1;
        if(opcode == 3'b001) // NAND
          WNext = ~(W & num1);
        if(opcode == 3'b010) begin // SRL
          if(num1 <= 16) 
            WNext = W >> num1;
          else if(num1 <= 31)
            WNext = W << num1[3:0];
          else if(num1 <= 47) begin
            //WNext = {W[num1[3:0]-1:0],W[15:num1[3:0]]};
            WNext = (W << (16 - num1[3:0])) + (W >> num1[3:0]);
          end
          else
            WNext = (W >> (16 - num1[3:0])) + (W << num1[3:0]);
        end
        if(opcode == 3'b011) // GE
          WNext = W >= num1;
        if(opcode == 3'b101) // CP2W
           WNext = num1;
        if(opcode == 3'b110) begin // CPfW
           addr_toRAM = operand1;
           data_toRAM = W; 
           wrEn = 1;  
        end
        stateNext    = 0;
      end
      4: begin // SZ or JMP
        opcodeNext   = opcode;
        operand1Next = operand1;
        num1Next     = num1;
        WNext        = W;
        addr_toRAM   = W;
        wrEn         = 0;
        if(opcode == 3'b111) // JMP
          PCNext = num1[12:0];
        else if(num1 == 0)
          PCNext = PC + 2;
        else
          PCNext = PC + 1;
        stateNext = 0;
      end
      5: begin // indirect
        PCNext       = PC;
        opcodeNext   = opcode;
        operand1Next = operand1;
        num1Next     = num1;
        WNext        = W;
        addr_toRAM   = data_fromRAM;
        wrEn         = 0;
        if(opcode == 3'b110) begin // CPfW
          PCNext     = PC + 1;
          data_toRAM = W;
          wrEn       = 1;
          stateNext  = 0;
        end
        else
          stateNext    = 6;
      end
      6: begin
        PCNext       = PC;
        opcodeNext   = opcode;
        operand1Next = operand1;
        num1Next     = data_fromRAM;
        WNext        = W;
        addr_toRAM   = operand1;
        wrEn         = 0;
        if(opcode == 3'b100 || opcode == 3'b111) // SZ or JMP
          stateNext = 4;
        else
          stateNext = 3;
      end
      default: begin
        stateNext    = 0;
        PCNext       = 0;
        opcodeNext   = 0;
        operand1Next = 0;
        num1Next     = 0;
        WNext        = 0;
        addr_toRAM   = 0;
        wrEn         = 0;
        data_toRAM   = 0;
      end
    endcase
  
end    
endmodule



