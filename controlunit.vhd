LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
entity CONTRO is
port(clk1: in std_logic; --the clock of cpu
     zero: in std_logic; --data of acc is zero
     ena: in std_logic; --enable port
	  mulit_flag: IN  std_logic;
     opcode: in std_logic_vector(6 downto 0);--operation code
	  opcoaddressin: in std_logic_vector(16 downto 0);
	  opcoaddressout: out std_logic_vector(16 downto 0);
	  acc_datain: in std_logic_vector(23 downto 0);-------------------------------------------
	  ALUmode: out std_logic_vector(2 downto 0);
	  REGmode: out std_logic_vector(2 downto 0);
	  REGSel: out std_logic_vector(1 downto 0);
     Rd_pc: out std_logic; --make PC to read addres
     rd: out std_logic; --read from RAM
     wr: out std_logic; --write to RAM
	  REGwr_en: out std_logic;
	  acc_dataout: out std_logic_vector(23 downto 0);---------------------------------------------
	  CONTRO_data_busrequire: out std_logic;----------------------------------------
	  RAM_data_busrequire: out std_logic;
	  JUMP_address: out std_logic_vector(16 downto 0);
	  BEQ1_enable: out std_logic;
	  BEQ2_enable: out std_logic;
	  MUL1_enable: out std_logic;
	  MUL2_enable: out std_logic
	  );
end CONTRO;
architecture ARCH of CONTRO is
begin
main:process(clk1,ena,opcode)
type state_type is (clk_0,clk_1,clk_2,clk_3,clk_4,clk_5,clk_6,clk_7);
--define eight state represent for eight clocks
variable state:state_type;
--define codes for MOV,JMP,STO,
constant MOV:std_logic_vector:= "11000";
constant JMP:std_logic_vector:= "11001";
constant RST:std_logic_vector:= "11010";
constant STO:std_logic_vector:= "11011";
constant MUL1:std_logic_vector:= "11100";
constant MUL2:std_logic_vector:= "11101";
constant BEQ1:std_logic_vector:= "11110";
constant BEQ2:std_logic_vector:= "11111";
--define codes for ALU
constant ADD:std_logic_vector:= "10100";
constant ORR:std_logic_vector:= "10010";
constant XORR:std_logic_vector:= "10011";
constant ANDD:std_logic_vector:= "10001";
constant COM2:std_logic_vector:= "10101";
constant SUBB:std_logic_vector:= "10110";
--define codes for REG
constant WRI:std_logic_vector:= "00000";
constant INC:std_logic_vector:= "00001";
constant SHL:std_logic_vector:= "00010";
constant SHR:std_logic_vector:= "00011";
begin
if(clk1'event and clk1='0')then --the negative edge of clock
if(ena='0')then --state loop enable
Rd_pc <= '0';
rd <= '0';
wr <= '0';
ALUmode <= "ZZZ";
REGmode <= "ZZZ";
REGSel <= "ZZ";
state:=clk_0;
else--start decoder
case state is
when clk_0 =>
rd <= '0';
wr <= '0';
state:=clk_1;
REGwr_en <= '1';
CONTRO_data_busrequire <= '0';
RAM_data_busrequire <= '0';
when clk_1 =>
rd <= '0';
wr <= '0';
state:=clk_2;
when clk_2 =>
if(opcode(6 downto 2)=ADD or opcode(6 downto 2)=ORR or opcode(6 downto 2)=XORR or opcode(6 downto 2)=ANDD or opcode(6 downto 2)=COM2 or opcode(6 downto 2)=SUBB)then--ALU function
ALUmode(2 downto 0) <= opcode(4 downto 2);
Rd_pc <= '0';
REGmode <= "ZZZ";
REGSel <= "ZZ";
opcoaddressout <= "ZZZZZZZZZZZZZZZZZ";
BEQ1_enable <= '0';
BEQ2_enable <= '0';
state:=clk_3;
elsif(opcode(6 downto 2)=WRI or opcode(6 downto 2)=INC or opcode(6 downto 2)=SHL or opcode(6 downto 2)=SHR)then---REG function
REGmode(2 downto 0) <= opcode(4 downto 2);
Rd_pc <= '0';
ALUmode <= "ZZZ";
opcoaddressout <= opcoaddressin;
REGSel <= opcode(1 downto 0);
RAM_data_busrequire <='1';
BEQ1_enable <= '0';
BEQ2_enable <= '0';
state:=clk_3;
elsif(opcode(6 downto 2)=MOV)then
CONTRO_data_busrequire <= '1';
Rd_pc <= '0';
ALUmode <= "ZZZ";
REGmode(2 downto 0) <= opcode(4 downto 2);
REGSel <= opcode(1 downto 0);
acc_dataout <= acc_datain;
BEQ1_enable <= '0';
BEQ2_enable <= '0';
state:=clk_3;
elsif(opcode(6 downto 2)=JMP)then
Rd_pc <= '1';--read PCounter
BEQ1_enable <= '0';
BEQ2_enable <= '0';
ALUmode <= "ZZZ";
REGmode <= "ZZZ";
JUMP_address <= opcoaddressin;
REGSel <= "ZZ";
state:=clk_3;
elsif(opcode(6 downto 2)=STO)then
Rd_pc <= '0';
BEQ1_enable <= '0';
BEQ2_enable <= '0';
ALUmode <= "ZZZ";
REGmode <= "ZZZ";
opcoaddressout <= opcoaddressin;
REGSel <= "ZZ";
state:=clk_3;
wr <= '1';--write rom
elsif(opcode(6 downto 2)=MUL1)then
Rd_pc <= '0';
ALUmode <= "ZZZ";
REGmode <= "ZZZ";
REGSel <= "ZZ";
MUL1_enable <= '1';
BEQ1_enable <= '0';
BEQ2_enable <= '0';
state:=clk_3;
elsif(opcode(6 downto 2)=MUL2)then
BEQ1_enable <= '0';
BEQ2_enable <= '0';
Rd_pc <= '0';
ALUmode <= "ZZZ";
REGmode <= "ZZZ";
REGSel <= "ZZ";
MUL2_enable <= '1';
state:=clk_3;
elsif(opcode(6 downto 2)=BEQ1 and mulit_flag = '0')then
Rd_pc <= '0';
ALUmode <= "ZZZ";
REGmode <= "ZZZ";
REGSel <= "ZZ";
BEQ1_enable <= '1';
BEQ2_enable <= '0';
state:=clk_3;
elsif(opcode(6 downto 2)=BEQ2 and zero = '1')then
Rd_pc <= '0';
ALUmode <= "ZZZ";
REGmode <= "ZZZ";
REGSel <= "ZZ";
BEQ2_enable <= '1';
BEQ1_enable <= '0';
state:=clk_3;
end if;--end decoder
when clk_3 =>--------not finished
state:=clk_4;
when clk_4 =>--------not finished
state:=clk_5;
when clk_5 =>--------not finished
RAM_data_busrequire <= '0';
CONTRO_data_busrequire <= '0';
state:=clk_6;
when clk_6 =>--------not finished
if(opcode(6 downto 2)=ADD or opcode(6 downto 2)=ORR or opcode(6 downto 2)=XORR or opcode(6 downto 2)=ANDD or opcode(6 downto 2)=COM2 or opcode(6 downto 2)=SUBB)then--ALU function
REGwr_en <= '0';--if ALU function is used,REG will not be writen,thus ALU out will be stored in ACC
end if;
state:=clk_7;
when clk_7 =>--------not finished--
rd <= '0';
wr <= '0';
RAM_data_busrequire <= '0';
CONTRO_data_busrequire <= '0';
state:=clk_0;
MUL1_enable <= '0';
MUL2_enable <= '0';
end case;
end if;
end if;
end process main;
end ARCH;