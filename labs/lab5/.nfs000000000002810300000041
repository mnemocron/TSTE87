-- Timing controller generated from the DSP toolbox
-- Electronics Systems, http://www.es.isy.liu.se/

library ieee;
use ieee.std_logic_1164.all;

entity timingcontroller is
port(
clk, reset : in std_logic;
state : inout integer range 0 to 47);
end timingcontroller;

architecture generated of timingcontroller is
begin
process(clk, reset)
begin
if reset = '1' then 
 state <= 0; 
elsif rising_edge(clk) then
 if state = 47 then
state <= 0;
else
 state <= state +1;
end if;
end if;
end process;
end generated;
