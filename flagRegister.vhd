library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity flagregister is 
  generic (NBITS: natural:=24); 
    port(
	   clk:      in std_logic;
      input:    in std_logic_vector(23 downto 0);
		output:    out std_logic_vector(23 downto 0);
		input_ENA:  in std_logic; 
		rightshift_ENA: in std_logic; 
        reset:       in std_logic;
		Multi_flag:   out std_logic;
		zero_flag:   out std_logic
    );
end flagregister;

architecture ARCH of flagregister is
signal flagregister: std_logic_vector(23 downto 0);
begin
	process(clk,input,reset,flagregister) is begin
  if (clk'event and clk='1') then
  if (reset='1')then
  output <= "000000000000000000000000";
  else
		if input_ENA = '1' then 
			flagregister <= input;
	   end if;
		if rightshift_ENA = '1' then
		    
		   flagregister <= '0' & flagregister(23 downto 1);
			 Multi_flag <= flagregister(0);
		end if;
  end if;
  zero_flag <= not (flagregister(0) or flagregister(1) or flagregister(2) or flagregister(3) or flagregister(4) or flagregister(5) or flagregister(6) or flagregister(7) or flagregister(8) or flagregister(9) or flagregister(10) or flagregister(11) or flagregister(12) or flagregister(13) or flagregister(14) or flagregister(15) or flagregister(16) or flagregister(17) or flagregister(18) or flagregister(19) or flagregister(20) or flagregister(21) or flagregister(22) or flagregister(23));  
  end if;
  output <= flagregister;
  end process;
end ARCH;
