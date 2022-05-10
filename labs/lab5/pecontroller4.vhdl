-- PE controller generated from the DSP toolbox
-- Electronics Systems, http://www.es.isy.liu.se/

library ieee;
use ieee.std_logic_1164.all;

entity pecontroller4 is
port(
state : in integer range 0 to 47;
coefficient : out std_logic_vector(0 to 9);
start : out std_logic);
end pecontroller4;

architecture generated of pecontroller4 is
begin
with state select
coefficient <= 
"1110010100" when 6,
"1000111001" when 14,
"1111010000" when 22,
"1000111001" when 38,
"1111011110" when 46,
"----------" when others;
with state select
start <= 
'1' when 6,
'1' when 14,
'1' when 22,
'1' when 38,
'1' when 46,
'0' when others;

end generated;
