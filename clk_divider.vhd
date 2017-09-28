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
