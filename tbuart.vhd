library ieee;
use ieee.std_logic_1164.all;

entity tb_uart is
end entity;

architecture sim of tb_uart is
  constant CLK_PERIOD : time := 20 ns; -- 50 MHz

  signal clk         : std_logic := '0';
  signal rst         : std_logic := '0';
  signal tx_start    : std_logic := '0';
  signal tx_busy     : std_logic;
  signal tx          : std_logic;
  signal rx_valid    : std_logic;
  signal frame_error : std_logic;

  signal tx_data : std_logic_vector(7 downto 0) := (others => '0');
  signal rx_data : std_logic_vector(7 downto 0);
begin
  clk <= not clk after CLK_PERIOD / 2;

  -- TX output is connected directly to RX input for loopback testing.
  dut : entity work.uart_top
    generic map (
      CLK_HZ    => 50_000_000,
      BAUD_RATE => 9_600
    )
    port map (
      clk         => clk,
      rst         => rst,
      uart_rx_i   => tx,
      uart_tx_o   => tx,
      tx_start    => tx_start,
      tx_data     => tx_data,
      tx_busy     => tx_busy,
      rx_data     => rx_data,
      rx_valid    => rx_valid,
      frame_error => frame_error
    );

  stimulus : process
    procedure send(constant value : std_logic_vector(7 downto 0)) is
    begin
      wait until rising_edge(clk) and tx_busy = '0';

      tx_data  <= value;
      tx_start <= '1';

      wait until rising_edge(clk);
      tx_start <= '0';

      wait until rising_edge(clk) and rx_valid = '1';

      assert rx_data = value
        report "UART loopback data mismatch"
        severity failure;

      assert frame_error = '0'
        report "Unexpected framing error"
        severity failure;
    end procedure;
  begin
    rst <= '1';
    wait for 10 * CLK_PERIOD;
    rst <= '0';

    send(x"55");
    send(x"A3");
    send(x"00");

    report "UART loopback test passed" severity note;
    wait;
  end process;
end architecture;