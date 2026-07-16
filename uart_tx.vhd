library ieee;
use ieee.std_logic_1164.all;

entity uart_tx is
  generic (
    CLK_HZ    : positive := 100_000_000;
    BAUD_RATE : positive := 115_200
  );
  port (
    clk      : in  std_logic;
    rst      : in  std_logic;
    tx_start : in  std_logic;
    tx_data  : in  std_logic_vector(7 downto 0);
    tx       : out std_logic;
    tx_busy  : out std_logic
  );
end entity;

architecture rtl of uart_tx is
  constant CLKS_PER_BIT : positive := CLK_HZ / BAUD_RATE;

  type state_t is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
  signal state      : state_t := IDLE;
  signal tick_count : integer range 0 to CLKS_PER_BIT - 1 := 0;
  signal bit_index  : integer range 0 to 7 := 0;
  signal shift_reg  : std_logic_vector(7 downto 0) := (others => '0');
begin
  assert CLK_HZ >= BAUD_RATE
    report "CLK_HZ must be at least BAUD_RATE"
    severity failure;

  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state      <= IDLE;
        tick_count <= 0;
        bit_index  <= 0;
        shift_reg  <= (others => '0');
      else
        case state is
          when IDLE =>
            tick_count <= 0;
            if tx_start = '1' then
              shift_reg <= tx_data;
              state     <= START_BIT;
            end if;

          when START_BIT =>
            if tick_count = CLKS_PER_BIT - 1 then
              tick_count <= 0;
              bit_index  <= 0;
              state      <= DATA_BITS;
            else
              tick_count <= tick_count + 1;
            end if;

          when DATA_BITS =>
            if tick_count = CLKS_PER_BIT - 1 then
              tick_count <= 0;
              if bit_index = 7 then
                state <= STOP_BIT;
              else
                bit_index <= bit_index + 1;
              end if;
            else
              tick_count <= tick_count + 1;
            end if;

          when STOP_BIT =>
            if tick_count = CLKS_PER_BIT - 1 then
              tick_count <= 0;
              state      <= IDLE;
            else
              tick_count <= tick_count + 1;
            end if;
        end case;
      end if;
    end if;
  end process;

  tx <= '0' when state = START_BIT else
        shift_reg(bit_index) when state = DATA_BITS else
        '1';

  tx_busy <= '0' when state = IDLE else '1';
end architecture;