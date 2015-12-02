

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;
use work.types.all;

entity pixel_storage is
  generic (width_g : integer);
  port (clk              : in  bit_t;
        reset            : in  bit_t;
        enable           : in  bit_t;
        pixel_pair       : in  halfword_t;
        saved_pixel_pair : out halfword_t);
end entity;

architecture structure of pixel_storage is
  signal saved_pixel_row, next_saved_pixel_row
    : std_logic_vector(width_g - 1 downto 0);
begin
  saved_pixel_pair <= saved_pixel_row(width_g - 1 downto
                                      width_g - halfword_t'length);

  combinatorial_logic : process(enable, pixel_pair, saved_pixel_row)
  begin
    next_saved_pixel_row <= saved_pixel_row;

    if enable = '1' then
      next_saved_pixel_row <=
        saved_pixel_row(width_g - 1 - halfword_t'length downto 0) & pixel_pair;
    end if;
  end process;

  clock_controller : process(clk, reset)
  begin
    if reset = '1' then
      saved_pixel_row <= (others => '0');
    elsif rising_edge(clk) then
      saved_pixel_row <= next_saved_pixel_row;
    end if;
  end process;

end architecture;
