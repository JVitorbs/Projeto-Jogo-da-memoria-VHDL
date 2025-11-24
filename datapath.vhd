library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
  port(
    clk       : in  std_logic;
    clk_slow  : in  std_logic;             -- usado para modo SHOW (edge)
    reset     : in  std_logic;

    seq_load  : in  std_logic;              -- salvar novo passo (usa rnd_in)
    seq_next  : in  std_logic;              -- avançar mostrando
    seq_cmp   : in  std_logic;              -- pedir comparação / avanço do play_idx
    rnd_bit   : in  std_logic_vector(1 downto 0); -- 2-bit random from LFSR

    button_i  : in  std_logic_vector(3 downto 0); -- buttons debounced

    leds_o    : out std_logic_vector(3 downto 0);
    match_flag: out std_logic; -- '1' if pressed button matches current step
    end_flag  : out std_logic  -- '1' when show sequence finished (so controller moves on)
  );
end entity;

architecture rtl of datapath is

  constant MAX_STEPS : integer := 8;

  type seq_array is array(0 to MAX_STEPS-1) of std_logic_vector(1 downto 0);
  signal sequence : seq_array := (others => (others => '0'));

  signal step_count : integer range 0 to MAX_STEPS := 0; -- how many steps in current sequence
  signal show_idx   : integer range 0 to MAX_STEPS := 0; -- index during SHOW
  signal play_idx   : integer range 0 to MAX_STEPS := 0; -- index during player input

  signal leds_reg : std_logic_vector(3 downto 0) := (others => '0');
  signal clk_slow_prev : std_logic := '0';

  signal btn_prev : std_logic_vector(3 downto 0) := (others => '0');
  signal pressed_idx : integer range -1 to 3 := -1;
  signal any_pressed : std_logic := '0';
  signal btn_pressed_reg : std_logic := '0';

  signal correct_reg : std_logic := '0';
  signal seq_done_reg: std_logic := '0';

begin

  ------------------------------------------------------------------
  -- Store new step when seq_load pulses
  ------------------------------------------------------------------
  proc_gen: process(clk, reset)
  begin
    if reset = '1' then
      step_count <= 0;
      sequence <= (others => (others => '0'));
    elsif rising_edge(clk) then
      if seq_load = '1' then
        if step_count < MAX_STEPS then
          sequence(step_count) <= rnd_bit;
          step_count <= step_count + 1;
        end if;
      end if;
    end if;
  end process;

  ------------------------------------------------------------------
  -- SHOW sequence using clk_slow edges
  ------------------------------------------------------------------
  proc_show: process(clk, reset)
  begin
    if reset = '1' then
      show_idx <= 0;
      leds_reg <= (others => '0');
      seq_done_reg <= '0';
      clk_slow_prev <= '0';
    elsif rising_edge(clk) then
      -- detect rising edge of clk_slow
      if clk_slow = '1' and clk_slow_prev = '0' and seq_next = '1' then
        if show_idx < step_count then
          -- light LED corresponding to sequence(show_idx) for one slow tick
          leds_reg <= (others => '0');
          leds_reg(to_integer(unsigned(sequence(show_idx)))) <= '1';
          show_idx <= show_idx + 1;
          seq_done_reg <= '0';
        else
          -- finished showing
          leds_reg <= (others => '0');
          seq_done_reg <= '1';
          show_idx <= 0;
        end if;
      end if;

      if seq_next = '0' then
        -- reset show state
        seq_done_reg <= '0';
        show_idx <= 0;
        leds_reg <= (others => '0');
      end if;

      clk_slow_prev <= clk_slow;
    end if;
  end process;

  ------------------------------------------------------------------
  -- BUTTON detection and compare (player input)
  ------------------------------------------------------------------
  proc_btn: process(clk, reset)
  begin
    if reset = '1' then
      btn_prev <= (others => '0');
      any_pressed <= '0';
      btn_pressed_reg <= '0';
      play_idx <= 0;
      correct_reg <= '0';
    elsif rising_edge(clk) then

      btn_pressed_reg <= '0';
      correct_reg <= '0';

      -- detect rising edge on buttons (debounced inputs expected)
      for i in 0 to 3 loop
        if button_i(i) = '1' and btn_prev(i) = '0' then
          pressed_idx <= i;
          any_pressed <= '1';
        end if;
      end loop;

      btn_prev <= button_i;

      if any_pressed = '1' then
        btn_pressed_reg <= '1';
        -- compare with current play_idx
        if pressed_idx = to_integer(unsigned(sequence(play_idx))) then
          correct_reg <= '1';
        else
          correct_reg <= '0';
        end if;
        any_pressed <= '0';
      end if;

      -- controller pulses seq_cmp to confirm/advance index
      if seq_cmp = '1' then
        if correct_reg = '1' then
          if play_idx < MAX_STEPS then
            play_idx <= play_idx + 1;
          end if;
        else
          play_idx <= 0;
        end if;
      end if;

      -- when a new sequence is created, reset play_idx
      if seq_load = '1' then
        play_idx <= 0;
      end if;

    end if;
  end process;

  ------------------------------------------------------------------
  -- Outputs
  ------------------------------------------------------------------
  leds_o <= leds_reg;
  match_flag <= correct_reg;
  end_flag <= seq_done_reg;

end architecture;