library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;
use work.types.all;

entity pixel_reader is
  generic (start_read_address_g : integer;
           width_g              : integer);
  port (clk         : in  bit_t;        -- The clock.
        reset       : in  bit_t;        -- The reset signal. Active low.
        data        : in  halfword_t;
        enable      : in  bit_t;        -- The enable signal.
        enable_next : out bit_t;
        addr        : out word_t;
        pixel_row   : out std_logic_vector(width_g - 1 downto 0));  -- Request signal for data.
end entity;

architecture structure of pixel_reader is
  signal next_enable_next                   : bit_t;
  signal pixel_row_internal, next_pixel_row : std_logic_vector(width_g - 1 downto 0);

  signal addr_internal, next_addr : word_t;
begin

  pixel_row <= pixel_row_internal;
  addr      <= addr_internal;

  combinatorial_logic : process(enable, data)
  begin
    next_enable_next <= '0';
    next_pixel_row   <= pixel_row_internal;
    next_addr        <= addr_internal;

    if enable = '1' then
      -- Read and shift two pixels left
      next_pixel_row <= pixel_row_internal(width_g - 1 - HALFWORD_SIZE downto 0) & data;

      -- Jump to next memory address
      next_addr <= word_t(unsigned(addr_internal) + 1);

      next_enable_next <= '1';
    end if;
  end process;

  clock_controller : process(clk, reset)
  begin
    if reset = '1' then
      enable_next        <= '0';
      pixel_row_internal <= (others => '0');
      addr_internal      <= word_t(to_unsigned(start_read_address_g, word_t'length));
    elsif rising_edge(clk) then
      enable_next        <= next_enable_next;
      pixel_row_internal <= next_pixel_row;
      addr_internal      <= next_addr;
    end if;
  end process;

end architecture;
