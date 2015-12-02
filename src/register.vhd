library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity reg is
  generic (width_g : integer);
  port (clk    : in  bit_t;
        reset  : in  bit_t;
        enable : in  bit_t;
        d      : in  std_logic_vector(width_g - 1 downto 0);
        q      : out std_logic_vector(width_g - 1 downto 0));
end entity;

architecture structure of reg is
begin

  clock_controller : process(clk, reset)
  begin
    if reset = '1' then
      q <= (others => '0');
    elsif rising_edge(clk) then
      if enable = '1' then
        q <= d;
      end if;
    end if;
  end process;

end architecture;
