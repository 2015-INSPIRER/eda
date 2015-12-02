library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;
use work.types.all;

entity pixel_writer is
  generic (start_write_address_g : word_t);
  port (clk        : in  bit_t;
        reset      : in  bit_t;
        enable     : in  bit_t;
        pixel_pair : in  halfword_t;
        end_of_row : in  bit_t;
        addr       : out word_t;
        data       : out halfword_t);
end entity;

architecture structure of pixel_writer is
  signal write_address, next_write_address : word_t;
begin

  addr <= write_address;

  combinatorial_logic : process(enable, pixel_pair, write_address, end_of_row)
  begin
    next_write_address <= write_address;

    if end_of_row = '1' then
      next_write_address <= word_t(unsigned(write_address) + 2);
    end if;

    data <= x"0000";

    if enable = '1' then
      data <= pixel_pair;

      -- Jump to next memory address
      next_write_address <= word_t(unsigned(write_address) + 1);
    end if;
  end process;

  clock_controller : process(clk, reset)
  begin
    if reset = '1' then
      write_address <= start_write_address_g;
    elsif rising_edge(clk) then
      write_address <= next_write_address;
    end if;
  end process;

end architecture;
