library ieee;
use ieee.std_logic_1164.all;

entity uart_top is
  generic (
    CLK_HZ    : positive := 100_000_000;
    BAUD_RATE : positive := 115_200
  );
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;

    uart_rx_i   : in  std_logic;
    uart_tx_o   : out std_logic;

    tx_start    : in  std_logic;
    tx_data     : in  std_logic_vector(7 downto 0);
    tx_busy     : out std_logic;

    rx_data     : out std_logic_vector(7 downto 0);
    rx_valid    : out std_logic;
    frame_error : out std_logic
  );
end entity;

architecture rtl of uart_top is
begin
  tx_inst : entity work.uart_tx
    generic map (
      CLK_HZ    => CLK_HZ,
      BAUD_RATE => BAUD_RATE
    )
    port map (
      clk      => clk,
      rst      => rst,
      tx_start => tx_start,
      tx_data  => tx_data,
      tx       => uart_tx_o,
      tx_busy  => tx_busy
    );

  rx_inst : entity work.uart_rx
    generic map (
      CLK_HZ    => CLK_HZ,
      BAUD_RATE => BAUD_RATE
    )
    port map (
      clk           => clk,
      rst           => rst,
      rx            => uart_rx_i,
      rx_data       => rx_data,
      rx_valid      => rx_valid,
      framing_error => frame_error
    );
end architecture;