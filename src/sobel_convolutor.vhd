library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;
use work.constants.all;

entity sobel_convolutor is
  generic (sobel_mask_g : SOBEL_MASK);
  port (pixel_1 : in  signed(8 downto 0);
        pixel_2 : in  signed(8 downto 0);
        pixel_3 : in  signed(8 downto 0);
        pixel_4 : in  signed(8 downto 0);
        pixel_5 : in  signed(8 downto 0);
        pixel_6 : in  signed(8 downto 0);
        result  : out signed(17 downto 0));
end entity;

architecture structure of sobel_convolutor is
begin
  result <= pixel_1 * to_signed(sobel_mask_g(0), 9) +
            pixel_2 * to_signed(sobel_mask_g(1), 9) +
            pixel_3 * to_signed(sobel_mask_g(2), 9) +
            pixel_4 * to_signed(sobel_mask_g(3), 9) +
            pixel_5 * to_signed(sobel_mask_g(4), 9) +
            pixel_6 * to_signed(sobel_mask_g(5), 9);
end architecture;
