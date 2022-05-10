-- PE controller generated from the DSP toolbox
-- Electronics Systems, http://www.es.isy.liu.se/

library ieee;
use ieee.std_logic_1164.all;

entity pecontroller1 is
port(
state : in integer range 0 to 47;
coefficient : out std_logic_vector(0 to 9);
start : out std_logic);
end pecontroller1;

architecture generated of pecontroller1 is
begin
with state select
coefficient <= 
"0011100101" when 0,
"1100010100" when 8,
"1111011110" when 16,
"1110001101" when 24,
"1010100101" when 32,
"1111011110" when 40,
"----------" when others;
with state select
start <= 
'1' when 0,
'1' when 8,
'1' when 16,
'1' when 24,
'1' when 32,
'1' when 40,
'0' when others;

end generated;
