-- PE controller generated from the DSP toolbox
-- Electronics Systems, http://www.es.isy.liu.se/

library ieee;
use ieee.std_logic_1164.all;

entity pecontroller3 is
port(
state : in integer range 0 to 47;
coefficient : out std_logic_vector(0 to 9);
start : out std_logic);
end pecontroller3;

architecture generated of pecontroller3 is
begin
with state select
coefficient <= 
"1011011101" when 4,
"1010100101" when 12,
"1110010101" when 20,
"1010100101" when 36,
"1110000100" when 44,
"----------" when others;
with state select
start <= 
'1' when 4,
'1' when 12,
'1' when 20,
'1' when 36,
'1' when 44,
'0' when others;

end generated;
