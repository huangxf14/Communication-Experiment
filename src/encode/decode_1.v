`timescale 1ns / 1ps
module viterbi(
  input  clk1,
  input  clk2,
  input  reset,  //
  input  singlecode,
  output possiblecode,
  output ans);  
  reg[13:0]     code,codebuff;
  reg[3:0]      code_len;
  reg[2:0]      decode_len;
  reg[13:0]     newcode,newcode1,possible_code1,possible_code2,possible_code3,possible_code4;
  reg[3:0]      error1,error2,error3,error4; 
  reg[6:0]      decode,decode1,decode2,decode3,decode4;
  reg[6:0]      decode5;
   always@(posedge clk1)begin
   if(!reset)begin
        code   <=  0;
    codebuff  <=  0;
    code_len   <=  0;
  end
   else begin
   if(code_len == 4'b1101)
        code_len   <= 4'b0000;        
   else
        code_len  <= code_len + 1;
    codebuff <= {singlecode,codebuff[13:1]};
         if(code_len == 4'b0000)begin
              code <= codebuff;
             end
          else
              code <= code;
   end 
  end
   always@(posedge clk2)begin
  if(!reset)begin
       decode_len <= 0;
   possible_code1   <= 0;
   possible_code2   <= 0;
   possible_code3   <= 0;
   possible_code4   <= 0; 
   error1   <= 0;
   error2   <= 0;
   error3   <= 0;
   error4   <= 0;
   decode1 <= 0;
   decode2 <= 0;
   decode3 <= 0;
   decode4 <= 0;
  end
 else begin
   decode_len <= decode_len  + 1;
     case(decode_len)
       3'b000: begin
         possible_code1[1:0]  <= 2'b00;
         possible_code2[1:0]  <= 2'b00;
         possible_code3[1:0]  <= 2'b11;
         possible_code4[1:0]  <= 2'b11;
         possible_code1[13:2] <= 0;
         possible_code2[13:2] <= 0;
         possible_code3[13:2] <= 0;
         possible_code4[13:2] <= 0;
         error1  <= 0;
         error2  <= 0;
         error3  <= 0;
         error4  <= 0;    
         decode1[6]  <= 0;
         decode2[6]  <= 0;
         decode3[6]  <= 1;
         decode4[6]  <= 1;
      end
     3'b001 : begin
          possible_code1[3:2]  <= 2'b00;
          possible_code2[3:2]  <= 2'b11;
          possible_code3[3:2]  <= 2'b01;
          possible_code4[3:2]  <= 2'b10;     
       error1  <= {3'b000,0^code[0]} + {3'b000,0^code[1]} +
                   {3'b000,0^code[2]} + {3'b000,0^code[3]};
       error2  <= {3'b000,0^code[0]} + {3'b000,0^code[1]} +
                   {3'b000,1^code[2]} + {3'b000,1^code[3]};
       error3  <= {3'b000,1^code[0]} + {3'b000,1^code[1]} +
                   {3'b000,1^code[2]} + {3'b000,0^code[3]};
       error4  <= {3'b000,1^code[0]} + {3'b000,1^code[1]} +
                   {3'b000,0^code[2]} + {3'b000,1^code[3]};   
       decode1[5] <= 0;
       decode2[5] <= 1;
       decode3[5] <= 0;
       decode4[5] <= 1;
    end    
     3'b010 : begin
         //  a = 2'b00
     if(error1 + {3'b000,0^code[5]} + {3'b000,0^code[4]} >
         error3 + {3'b000,1^code[5]} + {3'b000,1^code[4]})
      begin
       error1 <= error3 + {3'b000,1^code[5]} + {3'b000,1^code[4]};
       possible_code1[3:0]    <= possible_code3[3:0];
       possible_code1[5:4]    <= 2'b11;
       decode1[4]     <= 1'b0;
       decode1[6:5]  <= decode3[6:5];
      end
     else begin 
       error1 <= error1 + {3'b000,0^code[5]} + {3'b000,0^code[4]};
       possible_code1[3:0]  <= possible_code1[3:0];
       possible_code1[5:4]  <= 2'b00;
       decode1[4]  <= 1'b0;
       decode1[6:5] <= decode1[6:5];
      end
     // b = 2'b10
     if(error1 + {3'b000,1^code[5]} + {3'b000,1^code[4]} >
         error3 + {3'b000,0^code[5]} + {3'b000,0^code[5]})
      begin
        error2  <= error3 + {3'b000,0^code[5]} + {3'b000,0^code[5]};
      possible_code2[3:0] <= possible_code3[3:0];
      possible_code2[5:4] <= 2'b00;
      decode2[4] <= 1;
      decode2[6:5] <= decode3[6:5];
     end
     else begin 
      error2 <= error1 + {3'b000,1^code[5]} + {3'b000,1^code[4]};
      possible_code2[3:0] <= possible_code1[3:0];
      possible_code2[5:4] <= 2'b11;
      decode2[4]  <= 1;
      decode2[6:5] <= decode1[6:5];
      end
     //c = 2'b01
     if(error2 + {3'b000,0^code[5]} + {3'b000,1^code[4]} >
         error4 + {3'b000,1 ^code[5]} + {3'b000,0^code[4]})
      begin
        error3  <=error4 + {3'b000,1 ^code[5]} + {3'b000,0^code[4]};
        possible_code3[3:0] <= possible_code4[3:0];
        possible_code3[5:4] <= 2'b10;
        decode3[4]  <= 0;
        decode3[6:5] <= decode4[6:5];
      end
     else begin
        error3  <= error2 + {3'b000,0^code[5]} + {3'b000,1^code[4]};
        possible_code3[3:0] <= possible_code2[3:0];
        possible_code3[5:4] <= 2'b01;
        decode3[4] <= 0;
        decode3[6:5] <= decode2[6:5];
      end     
     // c = 2'b11
     if(error2 + {3'b000,1^code[5]} + {3'b000,0^code[4]} >
          error4 + {3'b000,0^code[5]} + {3'b000,1^code[4]})
      begin
       error4 <= error4 + {3'b000,0^code[5]} + {3'b000,1^code[4]};
       possible_code4[3:0] <= possible_code4[3:0];
       possible_code4[5:4] <= 2'b01;
       decode4[4] <= 1;
       decode4[6:5] <= decode4[6:5];
      end
     else begin
       error4 <= error2 + {3'b000,1^code[5]} + {3'b000,0^code[4]};
       possible_code4[3:0] <= possible_code2[3:0];
       possible_code4[5:4] <= 2'b10;
       decode4[4] <= 1;
       decode4[6:5] <= decode2[6:5];
      end
    end
   3'b011 :begin  
         //a = 2'b00
         if(error1 + {3'b000,0^code[7]} + {3'b000,0^code[6]} >
          error3 + {3'b000,1^code[7]} + {3'b000,1^code[6]})
      begin
       error1  <= error3 + {3'b000,1^code[7]} + {3'b000,1^code[6]};
       possible_code1[5:0] <= possible_code3[5:0];
       possible_code1[7:6] <= 2'b11;
       decode1[3] <= 0;
       decode1[6:4] <= decode3[6:4];
      end
     else begin
       error1  <= error1 + {3'b000,0^code[7]} + {3'b000,0^code[6]};
       possible_code1[5:0] <= possible_code1[5:0];
       possible_code1[7:6] <= 2'b00;
       decode1[3] <= 0;
       decode1[6:4] <= decode1[6:4];
      end
     // b = 2'b10
     if(error1 + {3'b000,1^code[7]} + {3'b000, 1^code[6]} >
          error3+ {3'b000,0^code[7]} + {3'b000,0^code[6]})
      begin
       error2  <= error3 + {3'b000,0^code[7]} + {3'b000,0^code[6]};
       possible_code2[5:0] <= possible_code3[5:0];
       possible_code2[7:6] <= 2'b00;
       decode2[3] <= 1;
       decode2[6:4] <= decode3[6:4];
      end
     else begin
       error2 <= error1 + {3'b000,1^code[7]} + {3'b000, 1^code[6]};
       possible_code2[5:0]  <= possible_code1[5:0];
       possible_code2[7:6]  <= 2'b11;
       decode2[3]  <= 1;
       decode2[6:4] <= decode1[6:4];
      end
     //2'b01
     if(error2 + {3'b000,0^code[7]} + {3'b000,1^code[6]} >
         error4 + {3'b000,1^code[7]} + {3'b000,0^code[6]})
      begin
       error3  <= error4 + {3'b000,1^code[7]} + {3'b000,0^code[6]};
       possible_code3[5:0] <= possible_code4[5:0];
       possible_code3[7:6] <= 2'b10;
       decode3[3] <= 0;
       decode3[6:4] <= decode4[6:4];
      end
     else begin
                 error3  <= error2 + {3'b000,0^code[7]} + {3'b000,1^code[6]};
       possible_code3[5:0] <= possible_code2[5:0];
       possible_code3[7:6] <= 2'b01;
       decode3[3] <= 0;
       decode3[6:4] <= decode2[6:4];
      end
     // 2'b11
     if(error2 + {3'b000,1^code[7]} + {3'b000,0^code[6]} >
         error4 + {3'b000,0^code[7]} + {3'b000,1^code[6]})
      begin
                 error4  <= error4 + {3'b000,1^code[7]} + {3'b000,0^code[6]};
       possible_code4[5:0] <= possible_code4[5:0];
       possible_code4[7:6] <= 2'b01;
       decode4[3] <= 1;
       decode4[6:4] <= decode4[6:4];
      end
     else begin
       error4  <= error2 + {3'b000,0^code[7]} + {3'b000,1^code[6]};
       possible_code4[5:0] <= possible_code2[5:0];
       possible_code4[7:6] <= 2'b10;
       decode4[3] <= 1;
       decode4[6:4] <= decode2[6:4];
      end
      end
     3'b100 : begin
         // 2'b00
     if(error1 + {3'b000,0^code[9]} + {3'b000,0^code[8]} >
         error3 + {3'b000,1^code[9]} + {3'b000,1^code[8]})
      begin
       error1  <= error3 + {3'b000,1^code[9]} + {3'b000,1^code[8]};
       possible_code1[7:0] <= possible_code3[7:0];
       possible_code1[9:8] <= 2'b11;
       decode1[2] <= 0;
       decode1[6:3] <= decode3[6:3];
      end
       else begin
       error1 <= error1 + {3'b000,0^code[9]} + {3'b000,0^code[8]};
       possible_code1[7:0] <= possible_code1[7:0];
       possible_code1[9:8] <= 2'b00;
       decode1[2] <= 0;
       decode1[6:3] <= decode1[6:3];
      end
     //2'b10
     if(error1 + {3'b000,1^code[9]} + {3'b000,1^code[8]} >
         error3 + {3'b000,0^code[9]} + {3'b000,0^code[8]})
      begin
       error2 <= error3 + {3'b000,0^code[9]} + {3'b000,0^code[8]};
       possible_code2[7:0] <= possible_code3[7:0];
       possible_code2[9:8] <= 2'b00;
       decode2[2] <= 1;
       decode2[6:3] <= decode3[6:3];
      end
     else begin
       error2 <= error1 + {3'b000,1^code[9]} + {3'b000,1^code[8]};
       possible_code2[7:0] <= possible_code1[7:0];
       possible_code2[9:8] <= 2'b11;
       decode2[2] <= 1;
       decode2[6:3] <= decode1[6:3];
      end
     // 2'b01
     if(error2 +{3'b000,0^code[9]} + {3'b000,1^code[8]} >
         error4 + {3'b000,1^code[9]} + {3'b000,0^code[8]})
      begin
       error3      <= error4 + {3'b000,1^code[9]} + {3'b000,0^code[8]};
      possible_code3[7:0] <= possible_code4[7:0];
       possible_code3[9:8] <= 2'b10;
       decode3[2] <= 0;
       decode3[6:3] <= decode4[6:3];
      end
     else begin
       error3  <= error2 + {3'b000,0^code[9]} + {3'b000,1^code[8]};
       possible_code3[7:0] <= possible_code2[7:0];
       possible_code3[9:8] <= 2'b01;
       decode3[2] <= 0;
       decode3[6:3] <= decode2[6:3];
      end
     // 2'b11
     if(error2 + {3'b000,1^code[9]} + {3'b000,0^code[8]} >
         error4 + {3'b000,0^code[9]} + {3'b000,1^code[8]})
      begin
       error4 <= error4 + {3'b000,0^code[9]} + {3'b000,1^code[8]};
       possible_code4[7:0] <= possible_code4[7:0];
       possible_code4[9:8] <= 2'b01;
       decode4[2] <= 1;
       decode4[6:3] <= decode4[6:3];
      end
     else begin
       error4 <= error2 + {3'b000,1^code[9]} + {3'b000,0^code[8]};
       possible_code4[7:0] <= possible_code2[7:0];
       possible_code4[9:8] <= 2'b10;
       decode4[2] <= 1;
       decode4[6:3] <= decode2[6:3];
      end
    end
   3'b101: begin
         //2'b00
     if(error1 + {3'b000,0^code[11]} + {3'b000,0^code[10]} >
         error3 + {3'b000,1^code[11]} + {3'b000,1^code[10]})
      begin
        error1 <= error3 + {3'b000,1^code[11]} + {3'b000,1^code[10]};
      possible_code1[9:0] <= possible_code3[9:0];
      possible_code1[11:10] <= 2'b11;
      decode1[1]   <= 0;
      decode1[6:2] <= decode3[6:2];
      end
     else begin
        error1 <= error1 + {3'b000,0^code[11]} + {3'b000,0^code[10]};
      possible_code1[9:0]   <= possible_code1[9:0];
      possible_code1[11:10] <= 2'b00;
      decode1[1]   <= 0;
      decode1[6:2] <= decode1[6:2];
      end
     //2'b01
     if(error2 + {3'b000,0^code[11]} + {3'b000,1^code[10]} >
         error4 + {3'b000,1^code[11]} + {3'b000,0^code[10]})
                begin
       error3 <= error4 + {3'b000,1^code[11]} + {3'b000,0^code[10]};
       possible_code3[9:0]   <= possible_code4[9:0];
       possible_code3[11:10] <= 2'b10;
       decode3[1]   <= 0;
       decode3[6:2] <= decode4[6:2];
      end
     else begin
       error3 <= error2 + {3'b000,0^code[11]} + {3'b000,1^code[10]};
       possible_code3[9:0]   <= possible_code2[9:0];
       possible_code3[11:10] <= 2'b01;
       decode3[1]   <= 0;
       decode3[6:2] <= decode2[6:2];
      end
    end
   3'b110 : begin
               // 2'b00
      if(error1 + {3'b000,0^code[13]} + {3'b000,0^code[12]} >
          error3 + {3'b000,1^code[13]} + {3'b000,1^code[12]})
      begin
       error1 <= error3 + {3'b000,1^code[13]} + {3'b000,1^code[12]};
       possible_code1[11:0]    <= possible_code3[11:0];
       possible_code1[13:12]   <= 2'b11;
       newcode[11:0] <= possible_code3[11:0];
       newcode[13:12]<= 2'b11;
       decode1[0]     <= 0;
       decode1[6:1]   <= decode3[6:1];
      end
      else begin
       error1 <= error1 + {3'b000,0^code[13]} + {3'b000,0^code[12]};
       possible_code1[11:0]    <= possible_code1[11:0];
       possible_code1[13:12]   <= 2'b00;
       newcode[11:0] <= possible_code1[11:0];
       newcode[13:12]<= 2'b00;
       decode1[0]     <= 0;
       decode1[6:1]   <= decode1[6:1];
      end
     end    
 3'b111 :  decode5[6:0] <= decode1[6:0];   
   default :begin
         possible_code1[1:0] <= 2'b00;
         possible_code2[1:0] <= 2'b00;
         possible_code3[1:0] <= 2'b11;
         possible_code4[1:0] <= 2'b11;     
         error1  <= 0;
         error2  <= 0;
         error3  <= 0;
         error4  <= 0;     
         decode1 <= 0;
         decode2 <= 0;
         decode3 <= 0;
         decode4 <= 0;
    end
  endcase
  end
 end
  always@(posedge clk1)begin
    if(!reset)begin
   newcode1  <= 0;
   decode     <= 0;
   end
  else begin
   if(code_len == 1)begin
      decode    <= decode5;
      newcode1 <= newcode;
      end
     else begin 
    newcode1[13:0] <= {newcode1[0],newcode1[13:1]};
    if(code_len[0]==1)
       decode[6:0]  <= {decode[5:0],decode[6]};
   end
    end    
  end
    assign possiblecode = newcode1[0];
  assign ans = decode[6];
endmodule
