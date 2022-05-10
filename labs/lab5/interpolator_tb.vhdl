library ieee;
use ieee.std_logic_1164.all;

entity interpolator_tb is
    generic 
    (
        -- Change these
        -- Number of cells in memory 1
        constant cells1 : integer := 6;
        -- Number of cells in memory 2
        constant cells2 : integer := 10;

        -- Schedule time
        constant scheduletime : integer := 48;

        -- Coefficient wordlength
        constant coefficientwordlength : integer := 10;

        -- Clock period (for simulation use only)
        constant clockperiod : time := 10 ns
    );
end interpolator_tb;

architecture behavior of interpolator_tb is
-- Declaration of signals
    signal clock : std_logic := '0';
    signal reset : std_logic;
    signal state : integer range 0 to scheduletime-1;
    signal address1 : integer range 0 to cells1-1;
    signal address2 : integer range 0 to cells2-1;
    signal enable1 : std_logic;
    signal enable2 : std_logic;
    signal readwrite1 : std_logic;
    signal readwrite2 : std_logic;
    signal coeff1 : std_logic_vector(0 to coefficientwordlength-1);
    signal coeff2 : std_logic_vector(0 to coefficientwordlength-1);
    signal coeff3 : std_logic_vector(0 to coefficientwordlength-1);
    signal coeff4 : std_logic_vector(0 to coefficientwordlength-1);
    signal start1 : std_logic;
    signal start2 : std_logic;
    signal start3 : std_logic;
    signal start4 : std_logic;
    
    component memorycontroller1
    port
    (
        state : in integer range 0 to scheduletime-1;
        adress : out integer range 0 to cells1-1;
        enable, readwrite : out std_logic
    );
    end component;

    component memorycontroller2
    port
    (
        state : in integer range 0 to scheduletime-1;
        adress : out integer range 0 to cells2-1;
        enable, readwrite : out std_logic
    );
    end component;

    component timingcontroller
    port
    (
        clk, reset : in std_logic;
        state : inout integer range 0 to 47
    );
    end component;

    component pecontroller1
    port
    (
        state : in integer range 0 to scheduletime-1;
        coefficient : out std_logic_vector(0 to coefficientwordlength-1);
        start : out std_logic
    );
    end component;
        
    component pecontroller2
    port
    (
        state : in integer range 0 to scheduletime-1;
        coefficient : out std_logic_vector(0 to coefficientwordlength-1);
        start : out std_logic
    );
    end component;
        
    component pecontroller3
    port
    (
        state : in integer range 0 to scheduletime-1;
        coefficient : out std_logic_vector(0 to coefficientwordlength-1);
        start : out std_logic
    );
    end component;
        
    component pecontroller4
    port
    (
        state : in integer range 0 to scheduletime-1;
        coefficient : out std_logic_vector(0 to coefficientwordlength-1);
        start : out std_logic
    );
    end component;
        
begin

    memcon1 : memorycontroller1
    port map
    (
        state => state,
        adress => address1,
        enable => enable1,
        readwrite => readwrite1
    );

    memcon2 : memorycontroller2
    port map
    (
        state => state,
        adress => address2,
        enable => enable2,
        readwrite => readwrite2
    );
   
    timcon : timingcontroller
    port map
    (
        clk => clock,
        reset => reset,
        state => state
    );
    
    pecon1 : pecontroller1
    port map
    (
        state => state,
        coefficient => coeff1,
        start => start1
    );
    
    pecon2 : pecontroller2
    port map
    (
        state => state,
        coefficient => coeff2,
        start => start2
    );
    
    pecon3 : pecontroller3
    port map
    (
        state => state,
        coefficient => coeff3,
        start => start3
    );
    
    pecon4 : pecontroller4
    port map
    (
        state => state,
        coefficient => coeff4,
        start => start4
    );
    
    clock <= not clock after clockperiod / 2;
    reset <= '1', '0' after clockperiod * 4;

end behavior;

