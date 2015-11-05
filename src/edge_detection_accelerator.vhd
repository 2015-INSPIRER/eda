-- -----------------------------------------------------------------------------
--
--  Title      :  Edge-Detection design project - task 2.
--             :
--  Developers :  Jonas Benjamin Borch - s052435@student.dtu.dk
--             :
--  Purpose    :  This design contains an entity for the accelerator that must be
--             :  build in task two of the Edge Detection design project. It
--             :  contains an architecture skeleton for the entity as well.
--             :
--             :
--  Revision   :  1.0    7-10-08     Final version
--             :  1.1    8-10-09     Split data line to dataR and dataW
--             :                     Edgar <s081553@student.dtu.dk>
--             :  1.2   12-10-11     Changed from std_loigc_arith to numeric_std
--             :
--  Special    :
--  thanks to  :  Niels Haandbæk -- c958307@student.dtu.dk
--             :  Michael Kristensen -- c973396@student.dtu.dk
--
-- -----------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- The entity for task two. Notice the additional signals for the memory.
-- reset is active low.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity edge_detection_accelerator is
  port (clk    : in  bit_t;             -- The clock.
        reset  : in  bit_t;             -- The reset signal. Active low.
        addr   : out word_t;            -- Address bus for data.
        dataR  : in  halfword_t;        -- The data bus.
        dataW  : out halfword_t;        -- The data bus.
        req    : out bit_t;             -- Request signal for data.
        rw     : out bit_t;             -- Read/Write signal for data.
        start  : in  bit_t;
        finish : out bit_t);
end edge_detection_accelerator;

--------------------------------------------------------------------------------
-- The desription of the accelerator.
--------------------------------------------------------------------------------

architecture structure of edge_detection_accelerator is

  type state_t is (idle, read_pixel, write_pixel, complete);

  -- All interanal signals are defined here
  signal state, next_state : state_t;

  signal read_addr, next_read_addr   : word_t := READ_START_ADDRESS;
  signal write_addr, next_write_addr : word_t := WRITE_START_ADDRESS;

  signal next_pixel, pixel : halfword_t;

begin

  dataW <= not pixel;

  -- Template for a process
  combinatorial_logic : process(start, read_addr, write_addr, state, dataR, pixel)
  begin
    rw              <= '1';
    req             <= '1';
    finish          <= '0';
    next_pixel      <= pixel;
    next_read_addr  <= read_addr;
    next_write_addr <= write_addr;

    case state is
      when idle =>
        req <= '0';

        if start = '1' then
          next_state <= read_pixel;
          req        <= '1';
        end if;
      when read_pixel =>
        next_read_addr <= word_t(unsigned(read_addr) + 1);
        addr           <= read_addr;
        next_pixel     <= dataR;

        next_state <= write_pixel;
      when write_pixel =>
        next_state      <= read_pixel;
        next_write_addr <= word_t(unsigned(write_addr) + 1);
        rw              <= '0';
        addr            <= write_addr;

        if write_addr = word_t(unsigned(WRITE_END_ADDRESS) - 1) then
          next_state <= complete;
        end if;
      when complete =>
        finish <= '1';
        req    <= '0';

        if start = '0' then
          next_state <= idle;
        end if;
    end case;
  end process combinatorial_logic;

  state_controller : process(clk, reset)
  begin
    if reset = '1' then
      state      <= idle;
      pixel      <= (others => '0');
      read_addr  <= (others => '0');
      write_addr <= WRITE_START_ADDRESS;
    elsif rising_edge(clk) then
      state      <= next_state;
      pixel      <= next_pixel;
      read_addr  <= next_read_addr;
      write_addr <= next_write_addr;
    end if;
  end process state_controller;

end structure;
