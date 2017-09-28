LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.std_logic_arith.ALL;
entity main is
port(CLK:in std_logic;
   ENA: in std_logic;
   RST: in std_logic;
	RD:  in std_logic;
	RDpc : IN std_logic;
	DATAIN:in std_logic_vector(23 downto 0);--data input to REGNA
	DATAOUT:out std_logic_vector(23 downto 0);--dataoutput from ALU
	INIADDRESS:in std_logic_vector(16 downto 0);
   ADDRESS:out std_logic_vector(16 downto 0);
   OPCODE:out std_logic_vector(6 downto 0);
	TEST0:out std_logic;
	TEST1:out std_logic;
	TEST2:out std_logic;
	TEST3:out std_logic;
	TEST4 : OUT  std_logic_vector(2 downto 0);
	TEST5 : OUT  std_logic_vector(16 downto 0);
	TEST6 : OUT  std_logic_vector(6 downto 0);
	TEST7 : OUT  std_logic_vector(1 downto 0);
	TEST8 : out std_logic_vector(23 downto 0)
        );
end main;
architecture behav of main is
--different component
    COMPONENT CONTRO
    PORT(
         clk1 : IN  std_logic;
         zero : IN  std_logic;
         ena : IN  std_logic;
			mulit_flag: IN  std_logic;
         opcode : IN  std_logic_vector(6 downto 0);
         opcoaddressin : IN  std_logic_vector(16 downto 0);
			acc_datain: in std_logic_vector(23 downto 0);
         opcoaddressout : OUT  std_logic_vector(16 downto 0);
         ALUmode : OUT  std_logic_vector(2 downto 0);
         REGmode : OUT  std_logic_vector(2 downto 0);
         REGSel : OUT  std_logic_vector(1 downto 0);
         Rd_pc : OUT  std_logic;
         rd : OUT  std_logic;
         wr : OUT  std_logic;
			REGwr_en: out std_logic;
			acc_dataout: out std_logic_vector(23 downto 0);
			CONTRO_data_busrequire : OUT  std_logic;
			RAM_data_busrequire : OUT  std_logic;
			JUMP_address: out std_logic_vector(16 downto 0);
			BEQ1_enable: out std_logic;
			BEQ2_enable: out std_logic;
			MUL1_enable: out std_logic;
			MUL2_enable: out std_logic
        );
    END COMPONENT;
	 
	   
    COMPONENT REGNA
    PORT(
         acc : OUT  std_logic_vector(23 downto 0);
         dr1 : OUT  std_logic_vector(23 downto 0);
         dr2 : OUT  std_logic_vector(23 downto 0);
         input : IN  std_logic_vector(23 downto 0);
         mode : IN  std_logic_vector(2 downto 0);
         regSelWr : IN  std_logic_vector(1 downto 0);
         writeEn : IN  std_logic;
         reset : IN  std_logic;
         clk : IN  std_logic;
	      acc_input: in std_logic_vector(23 downto 0);
			acc_out: OUT  std_logic_vector(23 downto 0)
        );
    END COMPONENT;
	 
      COMPONENT ALUNA
    PORT(
         alu_clk : IN  std_logic;
         alu_acc : IN  std_logic_vector(23 downto 0);
         alu_dr1 : IN  std_logic_vector(23 downto 0);
         alu_dr2 : IN  std_logic_vector(23 downto 0);
         mode : IN  std_logic_vector(2 downto 0);
         alu_ovfl : OUT  std_logic;
         zero : OUT  std_logic;
			alu_out : OUT  std_logic_vector(23 downto 0)
        );
    END COMPONENT;
 
  COMPONENT freqdivide
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         clk1 : OUT  std_logic;
         INR_clk : OUT  std_logic;
         alu_clk : OUT  std_logic;
         pc_clk : OUT  std_logic;
         REST_clk : OUT  std_logic;
         OUTen_clk : OUT  std_logic;
         REG_clk : OUT  std_logic;
         fetch : OUT  std_logic
        );
    END COMPONENT;

 COMPONENT rom--ROM----
    PORT(
         ADDRESS : IN  std_logic_vector(16 downto 0);
         ENA : IN  std_logic;
         RD : IN  std_logic;--read enable for ROM
         ROMINSTRUCTION : OUT  std_logic_vector(23 downto 0)
        );
    END COMPONENT;
	 
	  
    COMPONENT INSREG --INSTRUCTION REGISTER
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         ena : IN  std_logic;
         instruction : IN  std_logic_vector(23 downto 0);
         opcode : OUT  std_logic_vector(6 downto 0);
         opcoaddress : OUT  std_logic_vector(16 downto 0)
        );
    END COMPONENT;
	 
	  COMPONENT PCounter
    PORT(
         INRST_address : IN  std_logic_vector(16 downto 0);
         Rd : IN  std_logic;--read enable for ROM
         clock : IN  std_logic;
         reset : IN  std_logic;
         PCaddress : OUT  std_logic_vector(16 downto 0);
			BEQ_EN1: in std_logic;
			BEQ_EN2: in std_logic
        );
    END COMPONENT;
	 
	 COMPONENT Databuscontrol
    PORT(
         RAM_data_in : IN  std_logic_vector(23 downto 0);
         Control_data_in : IN  std_logic_vector(23 downto 0);
         ENA : IN  std_logic;
         controller_require : IN  std_logic;
         RAM_require : IN  std_logic;
         data_out : OUT  std_logic_vector(23 downto 0)
        );
    END COMPONENT;
	 
	 

	 
	   COMPONENT Mulitregister
    PORT(
         clk : IN  std_logic;
         input : IN  std_logic_vector(23 downto 0);
         output : OUT  std_logic_vector(23 downto 0);
         input_ENA : IN  std_logic;
         rightshift_ENA : IN  std_logic;
         reset : IN  std_logic;
         Muli_flag : OUT  std_logic;
         zero_flag : OUT  std_logic
        );
    END COMPONENT;
	 
signal sig1:std_logic_vector(23 downto 0);--Instruction from rom
signal sig2:std_logic_vector(16 downto 0);--pcout_address
signal sig3:std_logic;-----pc_clk
signal sig4:std_logic;--clk1,clock for controller
signal sig5:std_logic_vector(16 downto 0);--opcodeaddress between controller and ir_register
signal sig6:std_logic_vector(6 downto 0);--opcode between controller and ir_register
signal sig7:std_logic_vector(2 downto 0);--ALUmode between controller and ALU
signal sig8:std_logic_vector(2 downto 0);--REGmode between controller and REG
signal sig9:std_logic_vector(1 downto 0);--REGSel between controller and REG
signal sig10:std_logic_vector(23 downto 0);--DR1 signal between REGNA and ALU
signal sig11:std_logic_vector(23 downto 0);--DR2 signal between REGNA and ALU
signal sig12:std_logic_vector(23 downto 0);--ACC signal between REGNA and ALU
signal sig13:std_logic;--zero flag
signal sig14:std_logic;--IR_clk
signal sig15:std_logic;--ALU_clk
signal sig16:std_logic;--REG_clk
signal sig17:std_logic_vector(23 downto 0);--ALUoutput to ACC in REGNA
signal sig18:std_logic;--REGwrite_enalbe
signal sig19:std_logic_vector(23 downto 0);--ACC_data from controller to databuscontroller
signal sig20:std_logic;--CONTRO_data_busrequire
signal sig21:std_logic;--RAM_data_busrequire
signal sig22:std_logic_vector(23 downto 0);--DATAoutput from databus controller
signal sig23:std_logic;--Rd_PC
signal sig24:std_logic_vector(16 downto 0);--JMUP_address
signal sig25:std_logic;--BEQ_EN
signal sig26:std_logic;--ZERO FROM MULITER
signal sig27:std_logic;--MULIT FLAG FROM
signal sig28:std_logic;--MUL1_ENA
signal sig29:std_logic;--MUL2_ENA
signal sig30:std_logic;--OUTEN_clk
signal sig31:std_logic;--BEQ2

begin

U0:PCounter port map(sig24,sig23,sig3,RST,sig2,sig25,sig31);
U1:rom port map(sig2,ENA,RD,sig1);
U2:INSREG port map(sig14,RST,ENA,sig1,sig6,sig5);
U3:freqdivide port map(CLK,RST,sig4,sig14,sig15,sig3,OPEN,sig30,sig16,OPEN);
U4:CONTRO port map(sig4,sig26,ENA,sig27,sig6,sig5,sig12,OPEN,sig7,sig8,sig9,sig23,OPEN,OPEN,sig18,sig19,sig20,sig21,sig24,sig25,sig31,sig28,sig29);--test0 for sig18
U5:REGNA port map (sig12,sig10,sig11,sig22,sig8,sig9,sig18,RST,sig16,sig17,DATAOUT);--final dataout
U6:ALUNA port map (sig15,sig12,sig10,sig11,sig7,OPEN,OPEN,sig17);--TEST8 for sig17
U7:Databuscontrol port map (DATAIN,sig19,ENA,sig20,sig21,sig22);
U8:Mulitregister port map (sig30,sig11,TEST8,sig28,sig29,RST,sig27,sig26);



end behav;
---------------------------------INSREG-------------INSREG-------------INSREG-------------INSREG-------------INSREG
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
entity INSREG is
port(clk: in std_logic;--clock signal
reset: in std_logic;--reset
ena: in std_logic;--enable 
instruction: in std_logic_vector(23 downto 0);
opcode:out std_logic_vector(6 downto 0);
opcoaddress:out std_logic_vector(16 downto 0)
);
end INSREG;
architecture ARRCH of INSREG is
begin
main:process(clk,reset)
begin
if(clk'event and clk='1')then
if(reset='1')then
opcode <="1111111";
opcoaddress <="00000000000000000";
elsif(ena='1')then
opcode <=instruction (23 downto 17);
opcoaddress <= instruction (16 downto 0);
else
opcode <="ZZZZZZZ";
opcoaddress <="ZZZZZZZZZZZZZZZZZ";
end if;
else null;
end if;
end process main;
end ARRCH;
----------------------------ROM-------------------------ROM-------------------------ROM-------------------------ROM---------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;
entity rom is
port(
ADDRESS: in std_logic_vector(16 downto 0);
ENA: in std_logic;
RD: in std_logic;
ROMINSTRUCTION:out std_logic_vector(23 downto 0)
);
end rom;
architecture ARCH of rom is
begin
process(ADDRESS,ENA,RD)
type rom_array is array(0 to 131055) of std_logic_vector(23 downto 0);
variable mem:rom_array:=( 
("000000000000000000000000"),--0
("000000000000000000000000"),--1
("000001000000000000000000"),--2--MOV INTO DR1
("000001100000000000000000"),--3--MOV INTO DR2
("111000000000000000000000"),--4--MUL1 INTO MUL
("000001100000000000000000"),--3--MOV INTO DR2
("111010000000000000000110"),--5--SHR MUL
("111100000000000000000111"),--7--BEQ1,IF MULFLAG =1 ADD DR1 AND DR2
("101000000000000000001000"),--7--ADD DR1 AND DR2
("000101000000000000000000"),-----SHL DR1 
("110001100001010101010101"),--8--MOV ACC INTO DR2
("000000000000000000000100"),
("111110000001010101010101"),--8--BEQ2 IF ZERO =1 OUT,OR JUMP T 
("110010000000000000000110"),--9
("000000000000000000000000"),--6
("000000000000000000000000"),--5
("000000000000000000000000"),--
("000000000000000000000000"),--13
("000000000000000000000100"),--
("000000000000000000000100"),--15
("000000000000000000000100"),--
("000000000000000000000100"),--17
("000000000000000000000100"),--
("000000000000000000000100"),--19
("000000000000000000000100"),--
others=>("111111111111111111111111"));
begin
if(ENA='1' and RD='1')then
ROMINSTRUCTION<=mem((to_integer(unsigned(ADDRESS))));
else
ROMINSTRUCTION<=(others=>'Z');
end if;
end process;
end ARCH;
----------------------------------------PC counter------------------------PC counter------------------------PC counter------------------------PC counter-------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.std_logic_arith.ALL;
entity PCounter is
port(INRST_address:in std_logic_vector(16 downto 0);
Rd: in std_logic;
clock: in std_logic;
reset: in std_logic;
PCaddress:out std_logic_vector(16 downto 0);
BEQ_EN1: in std_logic;
BEQ_EN2: in std_logic
);
end PCounter;
architecture ARCH of PCounter is
signal pcreg:std_logic_vector(16 downto 0);
begin
process(reset,Rd,clock,INRST_address)
begin
if(reset='0')then
if(clock'event and clock='1')then
if(BEQ_EN1 = '1' OR BEQ_EN2 = '1')then
pcreg<=pcreg+'1'+'1';
else
if(Rd='0')then
pcreg<=pcreg+'1';
else pcreg<=INRST_address;
end if;
end if;
else null;
end if;
else
pcreg<="00000000000000000";
end if;
end process;
PCaddress<=pcreg;
end ARCH;

-----------------------------CLOCKDIVIDER----------------------------CLOCKDIVIDER----------------------------CLOCKDIVIDER----------------------------CLOCKDIVIDER---------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
entity freqdivide is
port(clk: in std_logic;
reset: in std_logic;
clk1:out std_logic;
INR_clk:out std_logic;
alu_clk: out std_logic;
pc_clk:out std_logic;
REST_clk:out std_logic;
OUTen_clk:out std_logic;
REG_clk:out std_logic;
fetch: out std_logic
);
end freqdivide;
architecture win of freqdivide is
begin
clk1<=not clk;
main:process(clk,reset)
type state_type is (S0,S1,S2,S3,S4,S5,S6,S7,S8);
variable state:state_type:=S0;
begin
if (reset='0')then
if(clk'event and clk='0')then
case state is
when S0 =>
OUTen_clk<='0';
REST_clk<='0';
alu_clk<='0';
pc_clk<='0';
fetch<='0';
INR_clk<='0';
REG_clk<='0';
state:=S1;
when S1 =>
REST_clk<='0';
pc_clk<='1';
state:=S2;
when S2 =>
pc_clk<='0';
INR_clk<='1';
state:=S3;
when S3 =>
INR_clk<='0';
fetch<='1';
state:=S4;
when S4 =>
INR_clk<='0';
state:=S5;
when S5 =>
REG_clk<='1';
state:=S6;
when S6 =>
alu_clk<='1';
REG_clk<='0';
state:=S7;
when S7 =>
alu_clk<='0';
fetch<='0';
state:=S8;
OUTen_clk<='1';
when S8 =>
state:=S1;
REST_clk<='1';
OUTen_clk<='0';
when others =>
state:=S0;
end case;
else null;
end if;
end if;
end process main;
end win;

--add reset function
-----------------------------CONTROLLER--------------------------CONTROLLER--------------------------CONTROLLER--------------------------CONTROLLER----------------
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
----------------------------ALU--------------------------------ALU--------------------------------ALU--------------------------------ALU---------------

library IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.std_logic_arith.ALL;
entity ALUNA is	-- N-bit 8-function ALU
	generic (NBITS: natural:=24);	--˿ڽ泣GENERIC([   [ : 趨ֵ ]볣ͬ ֻܴʵڲõֵ Ҳٸı ֵʵⲿṩ
		port(alu_clk: in std_logic;
		   alu_acc:	in std_logic_vector(NBITS-1 downto 0);--ACCĴ
			alu_dr1:	in std_logic_vector(NBITS-1 downto 0);--DR1Ĵ
			alu_dr2:	in std_logic_vector(NBITS-1 downto 0);--DR2Ĵ
			mode:		in std_logic_vector(2 downto 0);			--ALU mode control- 3 bits, 8 possibile choices
			alu_out:	out std_logic_vector(NBITS-1 downto 0);--output
			alu_ovfl:	out std_logic;
			zero: out std_logic
	  );
end ALUNA;
----------------------------
architecture ARCH of ALUNA is

signal c_in,c_out: std_logic_vector(NBITS-1 downto 0);--ڲźλλ
signal mid: std_logic_vector(NBITS-1 downto 0);--
signal modese1: std_logic_vector(2 downto 0);
signal modese2: std_logic_vector(2 downto 0);
signal modese3: std_logic_vector(2 downto 0);
signal modese4: std_logic_vector(2 downto 0);
signal not_result, adder_result, and_result, or_result, xor_result, adder_input1, adder_input2: std_logic_vector(NBITS-1 downto 0);--ڲź
----------------------
begin
   c_out(0) <= (adder_input1(0) AND adder_input2(0)) OR (adder_input1(0) AND c_in(0)) OR (adder_input2(0) AND c_in(0));
	adder_result(0) <= adder_input1(0) XOR adder_input2(0) XOR c_in(0);--
   GEN_REG:--ߣ
		for I in 1 to NBITS-1 generate -- Generate N ALU elements for componentfor generateΪͬһϵѭһּд
	c_in(I) <= c_out(I-1);--carry
		c_out(I) <= (adder_input1(I) AND adder_input2(I)) OR (adder_input1(I) AND c_in(I)) OR (adder_input2(I) AND c_in(I));
		adder_result(I) <= adder_input1(I) XOR adder_input2(I) XOR c_in(I);--fulladd
	end generate GEN_REG;
  
	modese1 <= mode;
	modese2 <= mode;
	modese3 <= mode;
	modese4 <= mode;
	 
	
	not_result <= not alu_acc;
	and_result <= alu_dr1 and alu_dr2;
	or_result <= alu_dr1 or alu_dr2;
	xor_result <= alu_dr1 xor alu_dr2;
	main:process(alu_clk,mode,alu_dr1,alu_dr2,c_in,c_out,mid)
	begin

if(alu_clk'event and alu_clk='1')then
   
  case modese1 is							--Select c_in to first bit based on mode.--with-select 䣬ֵΨһұΪsignal
	when "101"|"110" => c_in(0)<= '1';
	when others => c_in(0)<= '0';--Cin 1 for DR1-DR2 and DR2*, since B is negated in both scenarios!
	alu_ovfl <= c_in(NBITS-1) xor c_out(NBITS-1);	--Make the alu overflow xor of carry in/out on last bit
   end case;
	
	case modese2 is										--Select c_in to first bit based on mode.
		when "100" => adder_input1<= alu_dr1; 						--Case DR1+DR2
		when "110" => adder_input1<= alu_dr1; 
      when "101" => adder_input1<= (others  => '0');	
      when others => adder_input1<= (others  => '0');	
   end case;		--Case DR1-DR2 or DR2*. For both cases, make sure CIN(0) is 1.--
						--Case DR2*. Make sure CIN(0) is 1.
--Otherwise, 00 input to adder, and don't take output

	case modese3 is				--Select c_in to first bit based on mode.
	when "100" => adder_input2<= alu_dr2;--Case DR1+DR2
   when "110" => adder_input2<= not alu_dr2;			--Case DR1-DR2 or DR2*. For both cases, make sure CIN(0) is 1.
	when "101" => adder_input2<= not alu_dr2;			--Case DR2*. Make sure CIN(0) is 1.
	when others => adder_input2<= (others  => '0');
   end case;	--Otherwise, 00 input to adder, and don't take output
	
   
	else null;
end if;
  
	zero <= not (alu_acc(0) or alu_acc(1) or alu_acc(2) or alu_acc(3) or alu_acc(4) or alu_acc(5) or alu_acc(6) or alu_acc(7) or alu_acc(8) or alu_acc(9) or alu_acc(10) or alu_acc(11) or alu_acc(12) or alu_acc(13) or alu_acc(14) or alu_acc(15) or alu_acc(16) or alu_acc(17) or alu_acc(18) or alu_acc(19) or alu_acc(20) or alu_acc(21) or alu_acc(22) or alu_acc(23));
end process main;

main2:process(mode,adder_result,not_result,and_result,or_result,not_result)
begin
case mode is
	when "100"|"101"|"110" => alu_out<= adder_result;
	when "000" => alu_out<= not_result;
	when "001" => alu_out<= and_result;
	when "010" => alu_out<= or_result;
	when "011" => alu_out<= xor_result;
	when others => alu_out<= "ZZZZZZZZZZZZZZZZZZZZZZZZ";
	end case;
	end process main2;
   
end ARCH;
--000:Acc~
--001:DR1 and DR2
--010:DR1 or  DR2
--011:DR1 xor DR2
--100:DR1  +  DR2
--101:DR2*               --two's complement
--110:DR1  -  DR2
--111:SH?
--Change:zzzzzzzzzzzzzz when no output
--add clock

--------------------------------------------REGNA---------------REGNA---------------REGNA---------------REGNA--------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
-------------------------------
--Michael Cerabona
--Johns Hopkins University
--CAD VLSI Microprocessor Design
--11/15/15
--REGNA.vhd
-------------------------------
entity REGNA is -- N-bit 6-function regiser file
  generic (NBITS: natural:=24);  --generic Register width, default 24 bits
    port(acc:   out std_logic_vector(NBITS-1 downto 0);
      dr1:      out std_logic_vector(NBITS-1 downto 0);
      dr2:      out std_logic_vector(NBITS-1 downto 0);
      input:    in std_logic_vector(NBITS-1 downto 0);
      mode:     in std_logic_vector(2 downto 0);      --Register operation mode: 5 options: write, increment, shl, shr, clr: 000, 001, 010, 011, 100
      regSelWr: in std_logic_vector(1 downto 0);--01ACC--10DR1--11DR2
      writeEn:  in std_logic;                         --we expect that the writeEn signal is high for write, increment, shl, shr, clr ops.
      reset:       in std_logic;--actually reset
      clk:      in std_logic;
		acc_input: in std_logic_vector(NBITS-1 downto 0);
		acc_out: OUT  std_logic_vector(23 downto 0)
    );
end REGNA;
----------------------------
architecture ARCH of REGNA is
type bitFile is array(0 to 3) of std_logic_vector(NBITS-1 downto 0);
signal registerFile: bitFile;
signal incremented_values: bitFile;
signal left_shifted: bitFile;
signal right_shifted: bitFile;

----------------------------
begin
  --------------------------
  --hook up our register bit-slices to our internal signals
  incremented_values(0) <= std_logic_vector(unsigned(registerFile(0)) + 1);
  incremented_values(1) <= std_logic_vector(unsigned(registerFile(1)) + 1);
  incremented_values(2) <= std_logic_vector(unsigned(registerFile(2)) + 1);
  incremented_values(3) <= std_logic_vector(unsigned(registerFile(3)) + 1);
  
  left_shifted(0) <= registerFile(0)(NBITS-2 downto 0) & '0';
  left_shifted(1) <= registerFile(1)(NBITS-2 downto 0) & '0';
  left_shifted(2) <= registerFile(2)(NBITS-2 downto 0) & '0';
  left_shifted(3) <= registerFile(3)(NBITS-2 downto 0) & '0';
  
  right_shifted(0) <= '0' & registerFile(0)(NBITS-1 downto 1);
  right_shifted(1) <= '0' & registerFile(1)(NBITS-1 downto 1);
  right_shifted(2) <= '0' & registerFile(2)(NBITS-1 downto 1);
  right_shifted(3) <= '0' & registerFile(3)(NBITS-1 downto 1);
	process(clk,input,mode,reset,regSelWr,writeEn,registerFile) is begin


  --calculate our internal signals based on mode

  if (clk'event and clk='1') then
 
  if (reset='1')then
  acc <= "000000000000000000000000";
  dr1 <= "000000000000000000000000";
  dr2 <= "000000000000000000000000";
  else
	 if writeEn = '1' then
  
		if mode = "000" then      --write
			registerFile(to_integer(unsigned(regSelWr))) <= input;
			--input signal straight into register for write
		elsif mode = "001" then   --inc
			registerFile(to_integer(unsigned(regSelWr))) <= incremented_values(to_integer(unsigned(regSelWr)));
                                              --write incremented data to bit-slices
		elsif mode = "010" then   --shl
			registerFile(to_integer(unsigned(regSelWr))) <= left_shifted(to_integer(unsigned(regSelWr)));
                                              --write left-shifted data to bit-slices
		elsif mode = "011" then   --shr
			registerFile(to_integer(unsigned(regSelWr))) <= right_shifted(to_integer(unsigned(regSelWr)));
	   end if;
		
		end if; 
		
  end if;
  else 
  if writeEn = '0' then
		registerFile(1) <= acc_input;
		end if;
		
  end if;
      acc_out <= registerFile(1);
      acc <= registerFile(1);
	   dr1 <= registerFile(2);
	   dr2 <= registerFile(3);
  end process;
end ARCH;
-----------------------------DATABUSCONTROLLER------------------DATABUSCONTROLLER------------------DATABUSCONTROLLER------------------DATABUSCONTROLLER-----------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Databuscontrol is
port(RAM_data_in: in std_logic_vector(23 downto 0);
     Control_data_in: in std_logic_vector(23 downto 0);
	   ENA: in std_logic;
      controller_require: in std_logic;
		RAM_require: in std_logic;
     data_out: out std_logic_vector(23 downto 0)
);
end Databuscontrol;

architecture Behavioral of Databuscontrol is

begin
 process(controller_require,RAM_require,RAM_data_in,Control_data_in,ENA)
 begin
 if(ENA='1')then
 if(Controller_require='1')then
 data_out<=Control_data_in;
 elsif(Controller_require='0' and RAM_require='1')then
 data_out<=RAM_data_in;
 else
 data_out<="ZZZZZZZZZZZZZZZZZZZZZZZZ";
 end if;
 else  data_out<="ZZZZZZZZZZZZZZZZZZZZZZZZ";
 end if;
 end process;

end Behavioral;

---------------------------Observer-----------------------Observer-----------------------Observer-----------------------Observer-------------


------------------------------MULITIPLERREGISTER--------------------------MULITIPLERREGISTER--------------------------MULITIPLERREGISTER-------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
-------------------------------
--Michael Cerabona
--Johns Hopkins University
--CAD VLSI Microprocessor Design
--11/15/15
--REGNA.vhd
-------------------------------
entity Mulitregister is -- N-bit 6-function regiser file
  generic (NBITS: natural:=24);  --generic Register width, default 24 bits
    port(
	   clk:      in std_logic;
      input:    in std_logic_vector(23 downto 0);
		output:    out std_logic_vector(23 downto 0);
		input_ENA:  in std_logic; 
		rightshift_ENA: in std_logic; 
      reset:       in std_logic;--actually reset
		Muli_flag:   out std_logic;
		zero_flag:   out std_logic
    );
end Mulitregister;
----------------------------

architecture ARCH of Mulitregister is
signal mulitregister: std_logic_vector(23 downto 0);

----------------------------
begin

	process(clk,input,reset,mulitregister) is begin


  if (clk'event and clk='1') then
  if (reset='1')then
  output <= "000000000000000000000000";
  else
		if input_ENA = '1' then      --write
			mulitregister <= input;
	   end if;
		if rightshift_ENA = '1' then
		    
		   mulitregister <= '0' & mulitregister(23 downto 1);
			 Muli_flag <= mulitregister(0);
		end if;
  end if;
  zero_flag <= not (mulitregister(0) or mulitregister(1) or mulitregister(2) or mulitregister(3) or mulitregister(4) or mulitregister(5) or mulitregister(6) or mulitregister(7) or mulitregister(8) or mulitregister(9) or mulitregister(10) or mulitregister(11) or mulitregister(12) or mulitregister(13) or mulitregister(14) or mulitregister(15) or mulitregister(16) or mulitregister(17) or mulitregister(18) or mulitregister(19) or mulitregister(20) or mulitregister(21) or mulitregister(22) or mulitregister(23));  
  end if;
  output <= mulitregister;
 
   
  end process;
end ARCH;