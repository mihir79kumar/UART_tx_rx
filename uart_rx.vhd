library ieee;
use ieee.std_logic_1164.all;

entity uart_rx is
  generic (
    CLK_HZ    : positive := 100_000_000;
    BAUD_RATE : positive := 115_200
  );
  port (
    clk           : in  std_logic;
    rst           : in  std_logic;
    rx            : in  std_logic;
    rx_data       : out std_logic_vector(7 downto 0);
    rx_valid      : out std_logic;
    framing_error : out std_logic
  );
end entity;

architecture rtl of uart_rx is
  constant CLKS_PER_BIT : positive := CLK_HZ / BAUD_RATE;

  type state_t is (IDLE, START_CHECK, DATA_BITS, STOP_CHECK);

  signal state      : state_t := IDLE;
  signal tick_count : integer range 0 to CLKS_PER_BIT - 1 := 0;
  signal bit_index  : integer range 0 to 7 := 0;
  signal shift_reg  : std_logic_vector(7 downto 0) := (others => '0');

  signal rx_meta : std_logic := '1';
  signal rx_sync : std_logic := '1';
begin
  assert CLKS_PER_BIT >= 2
    report "Clock must provide at least two cycles per bit"
    severity failure;

  -- Synchronizer for asynchronous UART input
  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        rx_meta <= '1';
        rx_sync <= '1';
      else
        rx_meta <= rx;
        rx_sync <= rx_meta;
      end if;
    end if;
  end process;

  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state         <= IDLE;
        tick_count    <= 0;
        bit_index     <= 0;
        shift_reg     <= (others => '0');
        rx_data       <= (others => '0');
        rx_valid      <= '0';
        framing_error <= '0';
      else
        rx_valid      <= '0';
        framing_error <= '0';

        case state is
          when IDLE =>
            tick_count <= 0;
            if rx_sync = '0' then
              state <= START_CHECK;
            end if;

          when START_CHECK =>
            -- Verify start bit at its centre
            if tick_count = (CLKS_PER_BIT / 2) - 1 then
              tick_count <= 0;

              if rx_sync = '0' then
                bit_index <= 0;
                state     <= DATA_BITS;
              else
                state <= IDLE;
              end if;
            else
              tick_count <= tick_count + 1;
            end if;

          when DATA_BITS =>
            if tick_count = CLKS_PER_BIT - 1 then
              tick_count <= 0;
              shift_reg(bit_index) <= rx_sync;

              if bit_index = 7 then
                state <= STOP_CHECK;
              else
                bit_index <= bit_index + 1;
              end if;
            else
              tick_count <= tick_count + 1;
            end if;

          when STOP_CHECK =>
            if tick_count = CLKS_PER_BIT - 1 then
              tick_count    <= 0;
              rx_data       <= shift_reg;
              rx_valid      <= '1';
              framing_error <= not rx_sync;
              state         <= IDLE;
            else
              tick_count <= tick_count + 1;
            end if;
        end case;
      end if;
    end if;
  end process;
end architecture;