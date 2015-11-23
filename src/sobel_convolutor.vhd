library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;
use work.constants.all;

entity sobel_convolutor is
  generic (sobel_mask_g : SOBEL_MASK);
  port (pixel_1 : in  halfword_t;
        pixel_2 : in  halfword_t;
        pixel_3 : in  halfword_t;
        pixel_4 : in  halfword_t;
        pixel_5 : in  halfword_t;
        pixel_6 : in  halfword_t;
        result  : out byte_t);
end entity;

architecture structure of sobel_convolutor is
begin
  result <= pixel_1 * sobel_mask_g(0) +
            pixel_2 * sobel_mask_g(1) +
            pixel_3 * sobel_mask_g(2) +
            pixel_4 * sobel_mask_g(3) +
            pixel_5 * sobel_mask_g(4) +
            pixel_6 * sobel_mask_g(5);
end architecture;
