library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;
use work.constants.all;

entity pixel_calculator is
  port (row_1     : in  std_logic_vector(23 downto 0);
        row_2     : in  std_logic_vector(23 downto 0);
        row_3     : in  std_logic_vector(23 downto 0);
        pixel_out : out byte_t);
end entity;

architecture structure of pixel_calculator is

  component sobel_convolutor is
    generic (sobel_mask_g : SOBEL_MASK);
    port (pixel_1 : in  signed(8 downto 0);
          pixel_2 : in  signed(8 downto 0);
          pixel_3 : in  signed(8 downto 0);
          pixel_4 : in  signed(8 downto 0);
          pixel_5 : in  signed(8 downto 0);
          pixel_6 : in  signed(8 downto 0);
          result  : out signed(8 downto 0));
  end component;

  signal D_x, D_y : signed(8 downto 0);

  -- i_sobel_convolutor_0
  signal pixel_1_conv_0, pixel_2_conv_0, pixel_3_conv_0,
    pixel_4_conv_0, pixel_5_conv_0, pixel_6_conv_0 : signed(8 downto 0);

  -- i_sobel_convolutor_1
  signal pixel_1_conv_1, pixel_2_conv_1, pixel_3_conv_1,
    pixel_4_conv_1, pixel_5_conv_1, pixel_6_conv_1 : signed(8 downto 0);
begin

  pixel_out <= byte_t(abs((D_x(7 downto 0))) + abs((D_y(7 downto 0))));

  --Gx constants
  -- [Gx_1 x Gx_2]
  -- [Gx_3 x Gx_4]
  -- [Gx_5 x Gx_6]
  pixel_1_conv_0 <= '0' & signed(row_1(23 downto 16));
  pixel_2_conv_0 <= '0' & signed(row_1(7 downto 0));
  pixel_3_conv_0 <= '0' & signed(row_2(23 downto 16));
  pixel_4_conv_0 <= '0' & signed(row_2(7 downto 0));
  pixel_5_conv_0 <= '0' & signed(row_3(23 downto 16));
  pixel_6_conv_0 <= '0' & signed(row_3(7 downto 0));

  i_sobel_convolutor_0 : sobel_convolutor
    generic map (sobel_mask_g => SOBEL_MASK_G_X)
    port map(pixel_1 => pixel_1_conv_0,
             pixel_2 => pixel_2_conv_0,
             pixel_3 => pixel_3_conv_0,
             pixel_4 => pixel_4_conv_0,
             pixel_5 => pixel_5_conv_0,
             pixel_6 => pixel_5_conv_0,
             result  => D_x);

  --Gy constants
  -- [Gy_1 Gy_2 Gy_3]
  -- [x    x    x   ]
  -- [Gy_4 Gy_5 Gy_6]
  pixel_1_conv_1 <= '0' & signed(row_1(23 downto 16));
  pixel_2_conv_1 <= '0' & signed(row_1(15 downto 8));
  pixel_3_conv_1 <= '0' & signed(row_1(7 downto 0));
  pixel_4_conv_1 <= '0' & signed(row_3(23 downto 16));
  pixel_5_conv_1 <= '0' & signed(row_3(15 downto 8));
  pixel_6_conv_1 <= '0' & signed(row_3(7 downto 0));

  i_sobel_convolutor_1 : sobel_convolutor
    generic map (sobel_mask_g => SOBEL_MASK_G_Y)
    port map(pixel_1 => pixel_1_conv_1,
             pixel_2 => pixel_2_conv_1,
             pixel_3 => pixel_3_conv_1,
             pixel_4 => pixel_4_conv_1,
             pixel_5 => pixel_5_conv_1,
             pixel_6 => pixel_6_conv_1,
             result  => D_y);

end architecture;
