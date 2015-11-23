-- -----------------------------------------------------------------------------
--
--  Title      :  Edge-Detection design project - task 2.
--             :
--  Developers :  Jonas Benjamin Borch - s052435@student.dtu.dk
--             :
--  Purpose    :  This design contains an entity for the accelerator that must be
--             :  build in task two of the Edge Detection design project. It
--             :  contains an architecture skeleton for the entity as well.
--             :
--             :
--  Revision   :  1.0    7-10-08     Final version
--             :  1.1    8-10-09     Split data line to dataR and dataW
--             :                     Edgar <s081553@student.dtu.dk>
--             :  1.2   12-10-11     Changed from std_loigc_arith to numeric_std
--             :
--  Special    :
--  thanks to  :  Niels Haandbæk -- c958307@student.dtu.dk
--             :  Michael Kristensen -- c973396@student.dtu.dk
--
-- -----------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- The entity for task two. Notice the additional signals for the memory.
-- reset is active low.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;
use work.types.all;

entity edge_detection_accelerator is
  port (clk    : in  bit_t;             -- The clock.
        reset  : in  bit_t;             -- The reset signal. Active low.
        addr   : out word_t;            -- Address bus for data.
        dataR  : in  halfword_t;        -- The data bus.
        dataW  : out halfword_t;        -- The data bus.
        req    : out bit_t;             -- Request signal for data.
        rw     : out bit_t;             -- Read/Write signal for data.
        start  : in  bit_t;
        finish : out bit_t);
end entity;

--------------------------------------------------------------------------------
-- The desription of the accelerator.
--------------------------------------------------------------------------------

architecture structure of edge_detection_accelerator is

  component pixel_reader is
    generic (start_read_address_g : word_t;
             width_g              : integer);
    port (clk         : in  bit_t;
          reset       : in  bit_t;
          enable      : in  halfword_t;
          enable_next : out halfword_t;
          addr        : out word_t;
          pixel_row   : out std_logic_vector(width_g downto 0));
  end component;

  component pixel_calculator is
    generic (sobel_mask_g : signed(5 downto 0));
    port (clk         : in  bit_t;
          reset       : in  bit_t;
          enable      : in  halfword_t;
          enable_next : out halfword_t;
          addr        : out word_t;
          pixel_row   : out std_logic_vector(3 * BYTE_SIZE downto 0));
  end component;

  -- Pixel reader entity? 2 components with generic port one with 8 and one
  -- with 6 pixels to read
  type state_t is (idle, read_pixels, write_pixels, complete);

  -- All internal signals are defined here
  signal state, next_state : state_t;

  signal write_addr : word_t;

  signal calc_enable, next_calc_enable : std_logic;

  signal matrix_row_1, matrix_row_2, matrix_row_3 :
    std_logic_vector(MATRIX_WIDTH downto 0);

  signal pixel_reader_0_addr, pixel_reader_1_addr, pixel_reader_2_addr : word_t;

  signal enable_pixel_reader_0, enable_pixel_reader_1,
    enable_pixel_reader_2, enable_pixel_reader_0_next : bit_t;

  signal column_count, next_column_count : state_t;

begin

  -- Template for a process
  combinatorial_logic : process(start, write_addr, state, dataR)
  begin
    rw     <= '1';
    req    <= '1';
    finish <= '0';

    next_column_count <= column_count;
    next_calc_enable  <= '0';

    -- Multiplexed signal that depends on the last pixel reader, start signal
    -- and saved pixel count
    enable_pixel_reader_0 <= enable_pixel_reader_0_next;

    addr <= pixel_reader_0_addr;

    case state is
      when idle =>
        req <= '0';

        if start = '1' then
          next_state            <= read_pixel;
          req                   <= '1';
          enable_pixel_reader_0 <= '1';
        end if;
      when read_pixels =>
        next_state <= read_pixel;
        req        <= '1';

        -- Multiplex memory address based on the enabled pixel reader
        -- component, 0 -> 1 -> 2 -> 0 -> 1...
        if enable_pixel_reader_1 = '1' then
          addr <= pixel_reader_1_addr;
        elsif enable_pixel_reader_2 = '1' then
          addr              <= pixel_reader_2_addr;
          next_column_count <= column_count + 2;

          -- Get ready to calculate, unless it's the beginning of a row
          next_calc_enable <= '1';
          if column_count = IMAGE_WIDTH + 2 or column_count = 0 then
            next_calc_enable <= '0';
          end if;
        end if;

        if saved_count = 16 then
          rw         <= '1';
          next_state <= write_pixels;
        end if;

      when write_pixels =>
        next_state      <= read_pixels;
        next_write_addr <= word_t(unsigned(write_addr) + 1);
        rw              <= '0';
        addr            <= write_addr;
        dataW           <= saved_pixel;  -- fetch from shift register
        if write_addr = word_t(unsigned(WRITE_END_ADDRESS) - 1) then
          next_state <= complete;
        end if;
      when complete =>
        finish <= '1';
        req    <= '0';

        if start = '0' then
          next_state <= idle;
        end if;
    end case;
  end process;

  state_controller : process(clk, reset)
  begin
    if reset = '1' then
      state       <= idle;
      write_addr  <= WRITE_START_ADDRESS;
      calc_enable <= '0';
    elsif rising_edge(clk) then
      state       <= next_state;
      write_addr  <= next_write_addr;
      calc_enable <= next_calc_enable;
    end if;
  end process;

  i_pixel_reader_0 : pixel_reader
    generic map (start_read_address_g => IMAGE_WIDTH * 0,
                 width_g              => MATRIX_WIDTH)
    port map(clk         => clk,
             reset       => reset,
             enable      => enable_pixel_reader_0,
             addr        => pixel_reader_0_addr,
             enable_next => enable_pixel_reader_1,
             pixel_row   => matrix_row_1);
  i_pixel_reader_1 : pixel_reader
    generic map (start_read_address_g => IMAGE_WIDTH * 1,
                 width_g              => MATRIX_WIDTH)
    port map(clk         => clk,
             reset       => reset,
             enable      => enable_pixel_reader_1,
             addr        => pixel_reader_1_addr,
             enable_next => enable_pixel_reader_2,
             pixel_row   => matrix_row_2);
  i_pixel_reader_2 : pixel_reader
    generic map (start_read_address_g => IMAGE_WIDTH * 2,
                 width_g              => MATRIX_WIDTH)
    port map(clk         => clk,
             reset       => reset,
             enable      => enable_pixel_reader_2,
             addr        => pixel_reader_2_addr,
             enable_next => enable_pixel_reader_0_next,
             pixel_row   => matrix_row_3);

  -- Calculation components 2 pixels per clock cycle
  i_pixel_calculator_0 : pixel_calculator
    port map(clk   => clk,
             reset => reset,
             row_1 => matrix_row_1(MATRIX_WIDTH downto MATRIX_WIDTH - 3 * BYTE_SIZE),
             row_2 => matrix_row_2(MATRIX_WIDTH downto MATRIX_WIDTH - 3 * BYTE_SIZE),
             row_3 => matrix_row_3(MATRIX_WIDTH downto MATRIX_WIDTH - 3 * BYTE_SIZE));

  i_pixel_calculator_1 : pixel_calculator
    port map(clk   => clk,
             reset => reset,
             row_1 => matrix_row_1(MATRIX_WIDTH - BYTE_SIZE downto (MATRIX_WIDTH - BYTE_SIZE) - 3 * BYTE_SIZE),
             row_2 => matrix_row_2(MATRIX_WIDTH - BYTE_SIZE downto (MATRIX_WIDTH - BYTE_SIZE) - 3 * BYTE_SIZE),
             row_3 => matrix_row_3(MATRIX_WIDTH - BYTE_SIZE downto (MATRIX_WIDTH - BYTE_SIZE) - 3 * BYTE_SIZE));

end structure;
