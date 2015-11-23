library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity pixel_calculator is
  port (row_1     : in  byte_t(2 downto 0);
        row_2     : in  byte_t(2 downto 0);
        row_3     : in  byte_t(2 downto 0);
        counter   : out unsigned (2 downto 0);  -- counter (0 to 7).
        pixel_out : out byte_t);                -- processed pixel.
end entity;

architecture structure of pixel_calculator is

  signal D_x, D_y : signed(7 downto 0);

  signal pixel_1, pixel_2, pixel_3, pixel_4, pixel_5, pixel_6 : signed(7 downto 0);

begin

  convolution : process (D_x, D_y, counter)
  begin
    pixel_out <= byte_t(abs(D_x) + abs(D_y));

    next_counter <= counter + 1;
  end process;

  clock_controller : process(clk, reset)
  begin
    if reset = '1' then
      counter <= (others => '0');
    elsif rising_edge(clk) then
      counter <= next_counter;
    end if;
  end process;

  i_sobel_convolutor_0 : sobel_convolutor
    generic map (sobel_mask_g => SOBEL_MASK_G_X)
    port map(clk     => clk,
             reset   => reset,
             pixel_1 => row_1(0),
             pixel_2 => row_1(2),
             pixel_3 => row_2(0),
             pixel_4 => row_2(2),
             pixel_5 => row_3(0),
             pixel_6 => row_3(2),
             result => D_x);

  i_sobel_convolutor_1 : sobel_convolutor
    generic map (sobel_mask_g => SOBEL_MASK_G_Y)
    port map(clk     => clk,
             reset   => reset,
             pixel_1 => row_1(0),
             pixel_2 => row_1(1),
             pixel_3 => row_1(2),
             pixel_4 => row_3(0),
             pixel_5 => row_3(1),
             pixel_6 => row_3(2),
             result => D_y);

end architecture;
