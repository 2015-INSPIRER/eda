-- -----------------------------------------------------------------------------
--
--  Title      :  Testbench for task 2 of the Edge-Detection design project.
--             :
--  Developers :  Jonas Benjamin Borch - s052435@student.dtu.dk
--             :
--  Purpose    :  This design contains an architecture for the testbench used in
--             :  task 2 of the Edge-Detection design project.
--             :
--             :
--  Revision   :  1.0    07-10-08    Initial version
--             :  1.1    08-10-09    Split data line to dataR and dataW
--             :                     Edgar <s081553@student.dtu.dk>
--             :
--  Special    :
--  thanks to  :  Niels Haandbæk -- c958307@student.dtu.dk
--             :  Michael Kristensen -- c973396@student.dtu.dk
--             :  Hans Holten-Lund -- hahl@imm.dtu.dk
-- -----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity top is
  port (
    clk_100mhz : in    std_logic;
    rst        : in    std_logic;
    led        : out   unsigned(0 downto 0);
    start      : in    std_logic;
    --memory interface
    memoe      : out   std_logic;
    memwr      : out   std_logic;
    memadv     : out   std_logic;
    ramcs      : out   std_logic;
    memclk     : out   std_logic;
    ramlb      : out   std_logic;
    ramub      : out   std_logic;
    memadr     : out   std_logic_vector(23 downto 1);
    memdb      : inout halfword_t
    );
end top;

architecture structure of top is
  component clockdivider is
    generic(div : real);
    port(reset  : in  std_logic;
         clkin  : in  std_logic;
         clkout : out std_logic
         );
  end component;

  signal clk    : bit_t;
  signal addr   : word_t;
  signal datar  : halfword_t;
  signal dataw  : halfword_t;
  signal req    : bit_t;
  signal rw     : bit_t;
  signal finish : bit_t;

  signal start_db : bit_t;

begin

  -- memory clock of 12.5 mhz
  -- read somewhere about the timing to be 80ns !!
  -- works faster in synchronous mode, but not tested
  clk_div_inst : clockdivider
    generic map (div => 8.0)
    port map (reset  => rst, clkin => clk_100mhz, clkout => clk);

  led(0) <= finish;

  accelerator : entity work.acc
    port map (clk    => clk,
              reset  => rst,
              addr   => addr,
              datar  => datar,
              dataw  => dataw,
              req    => req,
              rw     => rw,
              start  => start_db,
              finish => finish);



  memory : entity work.memory3
    port map(clk    => clk,
             rst    => rst,
             addr   => addr,
             datar  => datar,
             dataw  => dataw,
             rw     => rw,
             req    => req,
             memoe  => memoe,
             memwr  => memwr,
             memadv => memadv,
             ramcs  => ramcs,
             memclk => memclk,
             ramlb  => ramlb,
             ramub  => ramub,
             memadr => memadr,
             memdb  => memdb
             );

  debounce : entity work.debounce
    port map(
      clk      => clk,
      reset    => rst,
      sw       => start,
      db_level => start_db,
      db_tick  => open
      );

end structure;
