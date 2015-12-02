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
    generic (start_read_address_g : integer;
             width_g              : integer);
    port (clk       : in  bit_t;
          reset     : in  bit_t;
          data      : in  halfword_t;
          enable    : in  bit_t;
          addr      : out word_t;
          pixel_row : out std_logic_vector(width_g - 1 downto 0));
  end component;

  component pixel_calculator is
    port (row_1     : in  std_logic_vector(23 downto 0);
          row_2     : in  std_logic_vector(23 downto 0);
          row_3     : in  std_logic_vector(23 downto 0);
          pixel_out : out byte_t);
  end component;

  component pixel_storage is
    generic (width_g : integer);
    port (clk              : in  bit_t;
          reset            : in  bit_t;
          enable           : in  bit_t;
          pixel_pair       : in  halfword_t;
          saved_pixel_pair : out halfword_t);
  end component;

  component pixel_writer is
    generic (start_write_address_g : word_t);
    port (clk                    : in  bit_t;
          reset                  : in  bit_t;
          enable                 : in  bit_t;
          pixel_pair             : in  halfword_t;
          end_of_row : in bit_t;
          addr                   : out word_t;
          data                   : out halfword_t);
  end component;

  -- States
  type state_t is (idle, pixel_reader_0, pixel_reader_1, pixel_reader_2,
                   pixel_writer_0, complete);
  signal state, next_state : state_t;

  -- Pixel reader signals
  signal enable_pixel_reader_0, enable_pixel_reader_1, enable_pixel_reader_2 : bit_t;
  signal pixel_reader_0_addr, pixel_reader_1_addr, pixel_reader_2_addr       : word_t;

  signal column_count, next_column_count : unsigned(15 downto 0) := to_unsigned(0, 16);

  -- Calculation component signals
  signal matrix_row_1, matrix_row_2, matrix_row_3,
    next_matrix_row_1, next_matrix_row_2, next_matrix_row_3 :
    std_logic_vector(MATRIX_WIDTH - 1 downto 0);

  -- Storage component signals
  signal enable_pixel_storage_0            : bit_t;
  signal saved_counter, next_saved_counter : unsigned(4 downto 0);
  signal save_pixel_0, save_pixel_1        : byte_t;

  signal pixel_pair, saved_pixel_pair : halfword_t;

  -- Pixel writer signals
  signal enable_pixel_writer_0  : bit_t;
  signal pixel_writer_0_addr    : word_t;
  signal written_counter, next_written_counter : unsigned(4 downto 0);
  signal end_of_row_writer : bit_t;

begin

  pixel_pair <= save_pixel_1 & save_pixel_0;

  -- Template for a process
  combinatorial_logic : process(start, state, column_count,
                                pixel_reader_0_addr,
                                pixel_reader_1_addr,
                                pixel_reader_2_addr,
                                pixel_writer_0_addr,
                                saved_counter,
                                written_counter)
  begin
    rw     <= '1';
    req    <= '1';
    finish <= '0';

    next_state <= state;

    enable_pixel_reader_0  <= '0';
    enable_pixel_reader_1  <= '0';
    enable_pixel_reader_2  <= '0';
    enable_pixel_storage_0 <= '0';
    end_of_row_writer <= '0';
    next_saved_counter     <= saved_counter;
    enable_pixel_writer_0  <= '0';
    next_written_counter     <= written_counter;

    next_column_count <= column_count;

    addr <= (others => '0');

    case state is
      when idle =>
        req <= '0';

        if start = '1' then
          req <= '1';

          next_state            <= pixel_reader_0;
          enable_pixel_reader_0 <= '1';
          addr                  <= pixel_reader_0_addr;
        end if;
      when pixel_reader_0 =>
        req <= '1';

        next_state            <= pixel_reader_1;
        enable_pixel_reader_1 <= '1';
        addr                  <= pixel_reader_1_addr;
      when pixel_reader_1 =>
        req <= '1';

        next_state            <= pixel_reader_2;
        enable_pixel_reader_2 <= '1';
        addr                  <= pixel_reader_2_addr;
        next_saved_counter     <= saved_counter + 2;

      when pixel_reader_2 =>
        req <= '1';

        next_state            <= pixel_reader_0;
        enable_pixel_reader_0 <= '1';
        addr                  <= pixel_reader_0_addr;

        -- Get ready to calculate, unless it's the beginning of a row
        enable_pixel_storage_0 <= '1';
        next_column_count <= column_count + 2;
        if column_count = IMAGE_WIDTH or column_count = 0 then
          enable_pixel_storage_0 <= '0';
        end if;

        -- 16 pixels are saved
        if saved_counter(4) = '1' then
          next_saved_counter <= (others => '0');

          enable_pixel_reader_0 <= '0';
          addr                  <= pixel_writer_0_addr;

          rw <= '0';

          enable_pixel_writer_0 <= '1';
          next_written_counter     <= written_counter + 2;
          next_state            <= pixel_writer_0;
        end if;

      when pixel_writer_0 =>
        next_state <= pixel_writer_0;
        next_written_counter     <= written_counter + 2;
        addr <= pixel_writer_0_addr;

        enable_pixel_writer_0 <= '1';

        enable_pixel_storage_0 <= '1';

        rw <= '0';
        req <= '1';

        if pixel_writer_0_addr = word_t(unsigned(WRITE_END_ADDRESS)) then
          next_state <= complete;
        elsif written_counter(4) = '1' then
          enable_pixel_writer_0 <= '0';
          next_written_counter     <= (others => '0');

          rw  <= '1';

          if column_count = IMAGE_WIDTH then
            next_column_count <= to_unsigned(2, column_count'length);
            end_of_row_writer <= '1';
          end if;

          enable_pixel_storage_0 <= '0';

          next_state            <= pixel_reader_0;
          enable_pixel_reader_0 <= '1';
          addr                  <= pixel_reader_0_addr;
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
      state         <= idle;
      column_count  <= (others => '0');
      saved_counter <= (others => '0');
      written_counter <= (others => '0');
    elsif rising_edge(clk) then
      state         <= next_state;
      column_count  <= next_column_count;
      saved_counter <= next_saved_counter;
      written_counter <= next_written_counter;
    end if;
  end process;

  -- Read 6x3 pixels over 9 clock cycles
  i_pixel_reader_0 : pixel_reader
    generic map (start_read_address_g => (IMAGE_WIDTH / 2) * 0,
                 width_g              => MATRIX_WIDTH)
    port map(clk       => clk,
             reset     => reset,
             data      => dataR,
             enable    => enable_pixel_reader_0,
             addr      => pixel_reader_0_addr,
             pixel_row => matrix_row_1);
  i_pixel_reader_1 : pixel_reader
    generic map (start_read_address_g => (IMAGE_WIDTH / 2) * 1,
                 width_g              => MATRIX_WIDTH)
    port map(clk       => clk,
             reset     => reset,
             data      => dataR,
             enable    => enable_pixel_reader_1,
             addr      => pixel_reader_1_addr,
             pixel_row => matrix_row_2);
  i_pixel_reader_2 : pixel_reader
    generic map (start_read_address_g => (IMAGE_WIDTH / 2) * 2,
                 width_g              => MATRIX_WIDTH)
    port map(clk       => clk,
             reset     => reset,
             data      => dataR,
             enable    => enable_pixel_reader_2,
             addr      => pixel_reader_2_addr,
             pixel_row => matrix_row_3);

  -- Calculation components 2 pixels per clock cycle
  i_pixel_calculator_0 : pixel_calculator
    port map(row_1 => matrix_row_1(MATRIX_WIDTH - 1 downto
                                   MATRIX_WIDTH - 3 * BYTE_SIZE),
             row_2 => matrix_row_2(MATRIX_WIDTH - 1 downto
                                   MATRIX_WIDTH - 3 * BYTE_SIZE),
             row_3 => matrix_row_3(MATRIX_WIDTH - 1 downto
                                   MATRIX_WIDTH - 3 * BYTE_SIZE),
             pixel_out => save_pixel_0);

  i_pixel_calculator_1 : pixel_calculator
    port map(row_1 => matrix_row_1(MATRIX_WIDTH - 1 - BYTE_SIZE downto
                                   (MATRIX_WIDTH - BYTE_SIZE) - 3 * BYTE_SIZE),
             row_2 => matrix_row_2(MATRIX_WIDTH - 1 - BYTE_SIZE downto
                                   (MATRIX_WIDTH - BYTE_SIZE) - 3 * BYTE_SIZE),
             row_3 => matrix_row_3(MATRIX_WIDTH - 1 - BYTE_SIZE downto
                                   (MATRIX_WIDTH - BYTE_SIZE) - 3 * BYTE_SIZE),
             pixel_out => save_pixel_1);

  -- Save pixels
  i_pixel_storage_0 : pixel_storage
    generic map (width_g => SAVE_COUNT * BYTE_SIZE)
    port map(clk              => clk,
             reset            => reset,
             enable           => enable_pixel_storage_0,
             pixel_pair       => pixel_pair,
             saved_pixel_pair => saved_pixel_pair);

  -- Write pixels
  i_pixel_writer_0 : pixel_writer
    generic map (start_write_address_g => WRITE_START_ADDRESS)
    port map(clk                    => clk,
             reset                  => reset,
             enable                 => enable_pixel_writer_0,
             pixel_pair             => saved_pixel_pair,
             end_of_row => end_of_row_writer,
             addr                   => pixel_writer_0_addr,
             data                   => dataW);

end architecture;
