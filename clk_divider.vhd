library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_divider is
  port (
    clk_in  : in  std_logic;  -- clock da placa (ex: 50 MHz)
    reset   : in  std_logic;  -- reset ativo alto
    clk_slow: out std_logic;  -- clock lento (toggle) para mostrar LEDs
    ms_tick : out std_logic   -- pulso 1 ms
  );
end entity;

architecture rtl of clk_divider is
  constant CLK_FREQ   : integer := 50000000; -- ajuste para seu clock (Hz)
  constant SLOW_HZ    : integer := 4;        -- frequência para avançar LED (Hz)
  constant SLOW_COUNT : integer := CLK_FREQ / SLOW_HZ / 2;
  constant MS_COUNT   : integer := CLK_FREQ / 1000;

  signal cnt_slow : integer range 0 to SLOW_COUNT := 0;
  signal cnt_ms   : integer range 0 to MS_COUNT := 0;
  signal slow_reg : std_logic := '0';
  signal ms_reg   : std_logic := '0';
begin
  process(clk_in, reset)
  begin
    if reset = '1' then
      cnt_slow <= 0; slow_reg <= '0';
      cnt_ms <= 0; ms_reg <= '0';
    elsif rising_edge(clk_in) then
      -- slow clock toggle
      if cnt_slow = SLOW_COUNT then
        cnt_slow <= 0;
        slow_reg <= not slow_reg;
      else
        cnt_slow <= cnt_slow + 1;
      end if;
      -- ms tick
      if cnt_ms = MS_COUNT-1 then
        cnt_ms <= 0;
        ms_reg <= '1';
      else
        cnt_ms <= cnt_ms + 1;
        ms_reg <= '0';
      end if;
    end if;
  end process;

  clk_slow <= slow_reg;
  ms_tick  <= ms_reg;
end architecture;