-- -------------------------------------------------------------------------
--
--  Title      :  Useful types and constants in a nice package.
--             :
--  Developers :  Jonas Benjamin Borch - s052435@student.dtu.dk
--             :
--  Purpose    :  This design contains a package with usefull types and
--             :  constants.
--             :
--  Revision   :  1.0  22-08-08  Initial version
--             :
--  Special    :
--  thanks to  :  Niels Haandbæk -- c958307@student.dtu.dk
--             :  Michael Kristensen - c973396@student.dtu.dk
--             :  Hans Holten-Lund - hahl@imm.dtu.dk
--
-- -------------------------------------------------------------------------

----------------------------------------------------------------------------
--    Type name |  MIPS name | size in bits
--        bit_t |     bit    | 1
--       byte_t |    byte    | 8
--   halfword_t |  halfword  | 16
--       word_t |    word    | 32
-- doubleword_t | doubleword | 64
-- The constants can be used to set all bits in a signal or variable of type
-- byte_t, halfword_t, word_t and doubleword_t to either '0', '1', 'X' or
-- 'Z'.
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package types is
  subtype bit_t is std_logic;
  subtype byte_t is std_logic_vector(7 downto 0);
  subtype halfword_t is std_logic_vector(15 downto 0);
  subtype word_t is std_logic_vector(31 downto 0);
  subtype doubleword_t is std_logic_vector(63 downto 0);

  constant byte_zero : byte_t := "00000000";
  constant byte_one  : byte_t := "11111111";
  constant byte_x    : byte_t := "XXXXXXXX";
  constant byte_z    : byte_t := "ZZZZZZZZ";

  constant halfword_zero : halfword_t := byte_zero & byte_zero;
  constant halfword_one  : halfword_t := byte_one & byte_one;
  constant halfword_x    : halfword_t := byte_x & byte_x;
  constant halfword_z    : halfword_t := byte_z & byte_z;

  constant word_zero : word_t := halfword_zero & halfword_zero;
  constant word_one  : word_t := halfword_one & halfword_one;
  constant word_x    : word_t := halfword_x & halfword_x;
  constant word_z    : word_t := halfword_z & halfword_z;

  constant doubleword_zero : doubleword_t := word_zero & word_zero;
  constant doubleword_one  : doubleword_t := word_one & word_one;
  constant doubleword_x    : doubleword_t := word_x & word_x;
  constant doubleword_z    : doubleword_t := word_z & word_z;

  -- Accelerator constants
  constant IMAGE_WIDTH : integer := 352;
  constant IMAGE_HEIGHT : integer := 288;
  constant NUM_PIXELS : integer := IMAGE_WIDTH * IMAGE_HEIGHT;

  constant READ_START_ADDRESS : word_t :=
    std_logic_vector(to_unsigned(0, word_t'length));
  constant READ_END_ADDRESS : word_t :=
    std_logic_vector(to_unsigned(((NUM_PIXELS / 2) - 1), word_t'length));
  constant WRITE_START_ADDRESS : word_t :=
    std_logic_vector(to_unsigned(NUM_PIXELS / 2, word_t'length));
  constant WRITE_END_ADDRESS : word_t :=
    std_logic_vector(to_unsigned(NUM_PIXELS - 1, word_t'length));

end types;

package body types is

end types;
