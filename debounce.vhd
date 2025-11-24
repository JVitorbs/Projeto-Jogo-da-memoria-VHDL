library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce is
  port (
    clk_ms  : in  std_logic;  -- 1 ms tick from clk_divider
    reset   : in  std_logic;  -- reset ativo alto
    btn_raw : in  std_logic;  -- sinal cru do botão (ativo alto)
    btn_out : out std_logic   -- botão filtrado
  );
end entity;

architecture beh of debounce is
  constant STABLE_MS : integer := 20; -- 20 ms de estabilidade
  signal cnt : integer range 0 to STABLE_MS := 0;
  signal sync, stable : std_logic := '0';
begin
  process(clk_ms, reset)
  begin
    if reset = '1' then
      cnt <= 0; sync <= '0'; stable <= '0';
    elsif rising_edge(clk_ms) then
      -- sincroniza e detecta mudança estável
      sync <= btn_raw;
      if sync = stable then
        cnt <= 0;
      else
        if cnt = STABLE_MS then
          stable <= sync;
          cnt <= 0;
        else
          cnt <= cnt + 1;
        end if;
      end if;
    end if;
  end process;

  btn_out <= stable;
end architecture;