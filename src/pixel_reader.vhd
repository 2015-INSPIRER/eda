library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;
use work.types.all;

entity pixel_reader is
  generic (start_read_address_g : word_t;
           width_g              : integer);
  port (clk         : in  bit_t;        -- The clock.
        reset       : in  bit_t;        -- The reset signal. Active low.
        enable      : in  halfword_t;   -- The enable signal.
        pixel_data  : in  halfword_t;   -- The data bus.
        enable_next : out halfword_t;
        addr        : out word_t;
        pixel_row   : out std_logic_vector(width_g downto 0));  -- Request signal for data.
end entity;

architecture structure of pixel_reader is
  signal enable_next, next_enable_next : bit_t;
  signal next_pixel_row                : std_logic_vector(width_g downto 0);

  signal read_address : word_t;
begin

  combinatorial_logic : process(enable, pixel_row, pixel_data, addr)
  begin
    next_enable_next <= '0';
    next_pixel_row   <= pixel_row;
    next_addr        <= addr;

    if enable = '1' then                -- probably not possible
      -- Read and shift two pixels left
      next_pixel_row <= pixel_row(width_g - HALFWORD_SIZE - 1 downto 0) & pixel_data;

      addr <= read_address;

      -- Jump to next memory address
      next_read_address <= read_address + 1;

      next_enable_next <= '1';
    end if;
  end process;

  clock_controller : process(clk, reset)
  begin
    if reset = '1' then
      enable_next <= '0';
      pixel_row   <= (others => '0');
      addr        <= read_start_address_g;
    elsif rising_edge(clk) then
      enable_next <= next_enable_next;
      pixel_row   <= next_pixel_row;
      addr        <= next_addr;
    end if;
  end process;

end architecture;
