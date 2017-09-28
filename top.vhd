LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.std_logic_arith.ALL;
entity main is
port(CLK:in std_logic;
   ENA: in std_logic;
   RST: in std_logic;
	RD:  in std_logic;
	DATAIN:in std_logic_vector(23 downto 0);
	DATAOUT:out std_logic_vector(23 downto 0);
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

 COMPONENT rom
    PORT(
         ADDRESS : IN  std_logic_vector(16 downto 0);
         ENA : IN  std_logic;
         RD : IN  std_logic;
         ROMINSTRUCTION : OUT  std_logic_vector(23 downto 0)
        );
    END COMPONENT;
	 
	  
    COMPONENT INSREG
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
	 
	 

	 
	   COMPONENT Flagregister
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
	 
signal sig1:std_logic_vector(23 downto 0);
signal sig2:std_logic_vector(16 downto 0);
signal sig3:std_logic;
signal sig4:std_logic;
signal sig5:std_logic_vector(16 downto 0);
signal sig6:std_logic_vector(6 downto 0);
signal sig7:std_logic_vector(2 downto 0);
signal sig8:std_logic_vector(2 downto 0);
signal sig9:std_logic_vector(1 downto 0);
signal sig10:std_logic_vector(23 downto 0);
signal sig11:std_logic_vector(23 downto 0);
signal sig12:std_logic_vector(23 downto 0);
signal sig13:std_logic;
signal sig14:std_logic;
signal sig15:std_logic;
signal sig16:std_logic;
signal sig17:std_logic_vector(23 downto 0);
signal sig18:std_logic;
signal sig19:std_logic_vector(23 downto 0);
signal sig20:std_logic;
signal sig21:std_logic;
signal sig22:std_logic_vector(23 downto 0);
signal sig23:std_logic;
signal sig24:std_logic_vector(16 downto 0);
signal sig25:std_logic;
signal sig26:std_logic;
signal sig27:std_logic;
signal sig28:std_logic;
signal sig29:std_logic;
signal sig30:std_logic;
signal sig31:std_logic;

begin

U0:PCounter port map(sig24,sig23,sig3,RST,sig2,sig25,sig31);
U1:rom port map(sig2,ENA,RD,sig1);
U2:INSREG port map(sig14,RST,ENA,sig1,sig6,sig5);
U3:freqdivide port map(CLK,RST,sig4,sig14,sig15,sig3,OPEN,sig30,sig16,OPEN);
U4:CONTRO port map(sig4,sig26,ENA,sig27,sig6,sig5,sig12,OPEN,sig7,sig8,sig9,sig23,OPEN,OPEN,sig18,sig19,sig20,sig21,sig24,sig25,sig31,sig28,sig29);--test0 for sig18
U5:REGNA port map (sig12,sig10,sig11,sig22,sig8,sig9,sig18,RST,sig16,sig17,DATAOUT);
U6:ALUNA port map (sig15,sig12,sig10,sig11,sig7,OPEN,OPEN,sig17);
U7:Databuscontrol port map (DATAIN,sig19,ENA,sig20,sig21,sig22);
U8:Mulitregister port map (sig30,sig11,TEST8,sig28,sig29,RST,sig27,sig26);
end behav;

entity INSREG is
port(clk: in std_logic;
reset: in std_logic;
ena: in std_logic;
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
