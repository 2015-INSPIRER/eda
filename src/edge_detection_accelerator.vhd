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

entity edge_detector_accelerator is
  port (clk    : in  bit_t;             -- The clock.
        reset  : in  bit_t;             -- The reset signal. Active low.
        addr   : out word_t;            -- Address bus for data.
        dataR  : in  halfword_t;        -- The data bus.
        dataW  : out halfword_t;        -- The data bus.
        req    : out bit_t;             -- Request signal for data.
        rw     : out bit_t;             -- Read/Write signal for data.
        start  : in  bit_t;
        finish : out bit_t);
end edge_detector_accelerator;

--------------------------------------------------------------------------------
-- The desription of the accelerator.
--------------------------------------------------------------------------------

architecture structure of edge_detector_accelerator is

  type state_type is (idle, read_pixel, invert, write_pixel, complete);

  -- All internal signals are defined here
  signal write_addr : word_t;
  signal read_addr  : word_t;

  signal pixel_in  : word_t;
  signal pixel_out : word_t;

begin
  -- Template for a process
  fsmd : process(clk, reset)
  begin
    rw <= '1';

    if reset = '0' then
      next_state <= idle;
      read_addr  <= READ_START_ADDRESS;
      write_addr <= WRITE_START_ADDRESS;
    elsif clk'event and clk = '1' then
      next_state <= state;

      case state is
        when idle =>
          req <= '0';

          if start = '1' then
            next_state <= read_pixel;
            req        <= '1';
          end if;
        when read_pixel =>
          pixel_in  <= dataR;
          read_addr <= read_addr + 1;

          next_state <= invert_pixel;
        when invert =>
          pixel_out <= not pixel_in;

          rw         <= '0';

          next_state <= write_pixel;
        when write_pixel =>
          next_state <= read_pixel;
          dataW      <= pixel_out;
          write_addr <= write_addr + 1;

          if write_addr = WRITE_END_ADDRESS - 1 then
            next_state <= complete;
          end if;
        when complete =>
          finish <= '1';
          req    <= '0';

          if start = '0' then
            next_state <= idle;
          end if;
      end case;
    end if;
  end process fsmd;

end structure;
