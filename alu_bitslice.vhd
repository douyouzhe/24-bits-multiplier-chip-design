library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity alu_bitslice is
	port(
	clk: in std_logic;
	a: in std_logic;
	b: in std_logic;
	op_code: in std_logic_vector(2 downto 0);
	z: out std_logic;
	c_out: out std_logic;
	c_in: in std_logic
	);
end alu_bitslice;

architecture Behavioral of alu_bitslice is
begin
	process(clk)
	begin
		if rising_edge(clk) then
			case op_code is
				when "000" => z<=not (a);
				when "001" => z<=a and b;
				when "010" => z<=a or b;
				when "011" => z<=a xor b;
				when "100" => z<=a xor b xor c_in; c_out<= (a and b) or (c_in and a) or (c_in and b);
				when "110" => z<=a xor b xor c_in; c_out<= (not(a) and b) or (c_in and not(a)) or (c_in and b);
				when others=> null ;
			end case;
		end if;
	end process;
end Behavioral;

