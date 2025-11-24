library ieee;
use ieee.std_logic_1164.all;

entity lfsr_rng is
  port(
    clk     : in  std_logic;
    reset   : in  std_logic;  -- reset ativo alto
    enable  : in  std_logic;  -- avança LFSR quando '1'
    rnd_out : out std_logic_vector(1 downto 0)
  );
end entity;

architecture rtl of lfsr_rng is
  signal lfsr : std_logic_vector(15 downto 0) := x"ACE1"; -- seed
begin
  process(clk, reset)
  begin
    if reset = '1' then
      lfsr <= x"ACE1";
    elsif rising_edge(clk) then
      if enable = '1' then
        -- taps: 16,14,13,11 (polynomial x^16 + x^14 + x^13 + x^11 + 1)
        lfsr <= lfsr(14 downto 0) & (lfsr(15) xor lfsr(13) xor lfsr(12) xor lfsr(10));
      end if;
    end if;
  end process;

  rnd_out <= lfsr(1 downto 0); -- pegue 2 LSBs
end architecture;