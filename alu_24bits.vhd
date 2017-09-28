--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--
--entity alu_24_bits is
--	port(
--	clk: in std_logic;
--	a: in std_logic_vector(23 downto 0);
--	b: in std_logic_vector(23 downto 0);
--	op_code: in std_logic_vector(2 downto 0);
--	z: out std_logic_vector(23 downto 0);
--	c_out: out std_logic;
--	c_in: in std_logic
--	);
--end alu_24_bits;
--
--architecture Behavioral of alu_24_bits is
--signal c_line: std_logic_vector(24 downto 0);
--component alu_bitslice
--	port(
--	clk: in std_logic;
--	a: in std_logic;
--	b: in std_logic;
--	op_code: in std_logic_vector(2 downto 0);
--	z: out std_logic;
--	c_out: out std_logic;
--	c_in: in std_logic
--	);
--end component;
--begin
--	
--	c_line(0)<=c_in;
--	c_out<=c_line(24);
--	
--   Gen:for I in 1 to 24 generate
--      REG : alu_bitslice 
--		port map(
--			clk=>clk,
--			a=>a(I-1),
--			b=>b(I-1),
--			op_code=>op_code,
--			z=>z(I-1),
--			c_out=>c_line(I),
--			c_in=>c_line(I-1)
--		);
--   end generate Gen;
--
--end Behavioral;

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
	alu_ovfl <= c_in(NBITS-1) or c_out(NBITS-1);	--Make the alu overflow xor of carry in/out on last bit
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
