library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_memory_game is
    port(
        clk        : in  std_logic;
        reset      : in  std_logic;

        buttons_i  : in  std_logic_vector(3 downto 0); -- raw buttons from board

        leds_o     : out std_logic_vector(3 downto 0)
    );
end entity;

architecture structural of top_memory_game is

    -- controller<>datapath handshake signals
    signal seq_load_s, seq_next_s, seq_cmp_s, rnd_en_s : std_logic;
    signal match_flag_s, end_flag_s : std_logic;

    -- clock divider outputs
    signal clk_slow_sig, ms_tick_sig : std_logic;

    -- lfsr output (2 bits)
    signal rnd_sig : std_logic_vector(1 downto 0);

    -- debounced buttons
    signal btn_clean : std_logic_vector(3 downto 0);

begin

    -------------------------------------------------------------------
    -- clk_divider instance (produces clk_slow and 1 ms tick)
    -------------------------------------------------------------------
    clkdiv: entity work.clk_divider
        port map(
            clk_in  => clk,
            reset   => reset,
            clk_slow=> clk_slow_sig,
            ms_tick => ms_tick_sig
        );

    -------------------------------------------------------------------
    -- LFSR RNG
    -------------------------------------------------------------------
    rng: entity work.lfsr_rng
        port map(
            clk     => clk,
            reset   => reset,
            enable  => rnd_en_s,
            rnd_out => rnd_sig
        );

    -------------------------------------------------------------------
    -- Debounce each button using ms_tick (1 ms)
    -------------------------------------------------------------------
    deb0: entity work.debounce port map(clk_ms => ms_tick_sig, reset => reset, btn_raw => buttons_i(0), btn_out => btn_clean(0));
    deb1: entity work.debounce port map(clk_ms => ms_tick_sig, reset => reset, btn_raw => buttons_i(1), btn_out => btn_clean(1));
    deb2: entity work.debounce port map(clk_ms => ms_tick_sig, reset => reset, btn_raw => buttons_i(2), btn_out => btn_clean(2));
    deb3: entity work.debounce port map(clk_ms => ms_tick_sig, reset => reset, btn_raw => buttons_i(3), btn_out => btn_clean(3));

    -------------------------------------------------------------------
    -- Datapath: recebe clk_slow for SHOW timing, rnd_sig for sequence values
    -------------------------------------------------------------------
    dp: entity work.datapath
        port map(
            clk       => clk,
            clk_slow  => clk_slow_sig,
            reset     => reset,
            seq_load  => seq_load_s,
            seq_next  => seq_next_s,
            seq_cmp   => seq_cmp_s,
            rnd_bit   => rnd_sig,
            button_i  => btn_clean,
            leds_o    => leds_o,
            match_flag=> match_flag_s,
            end_flag  => end_flag_s
        );

    -------------------------------------------------------------------
    -- Controller: simple FSM to request gen/show/check
    -------------------------------------------------------------------
    ctl: entity work.controller
        port map(
            clk        => clk,
            reset      => reset,
            match_flag => match_flag_s,
            end_flag   => end_flag_s,
            seq_load   => seq_load_s,
            seq_next   => seq_next_s,
            seq_cmp    => seq_cmp_s,
            rnd_en     => rnd_en_s
        );

end architecture;