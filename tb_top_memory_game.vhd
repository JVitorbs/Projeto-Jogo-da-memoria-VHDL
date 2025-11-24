library ieee;
use ieee.std_logic_1164.all;

entity tb_top_memory_game is
end entity;

architecture tb of tb_top_memory_game is

    -- sinais do testbench
    signal clk_tb       : std_logic := '0';
    signal reset_tb     : std_logic := '1';
    signal buttons_tb   : std_logic_vector(3 downto 0) := (others => '0');
    signal leds_tb      : std_logic_vector(3 downto 0);

begin

    --------------------------------------------------------------------
    -- DUT: Top-level do jogo da memória
    --------------------------------------------------------------------
    UUT: entity work.top_memory_game
        port map (
            clk        => clk_tb,
            reset      => reset_tb,
            buttons_i  => buttons_tb,
            leds_o     => leds_tb
        );

    --------------------------------------------------------------------
    -- clock de 50 MHz (período = 20 ns)
    --------------------------------------------------------------------
    clk_process : process
    begin
        clk_tb <= '0';
        wait for 10 ns;
        clk_tb <= '1';
        wait for 10 ns;
    end process;

    --------------------------------------------------------------------
    -- estímulos
    --------------------------------------------------------------------
    stim_proc : process
    begin
        
        -- mantém reset por 200 ns
        wait for 200 ns;
        reset_tb <= '0';

        ---------------------------------------------------------------
        -- aperta botões em sequência simulando o jogador
        ---------------------------------------------------------------
        
        -- aperta botão 0
        buttons_tb <= "0001";
        wait for 40 ns;
        buttons_tb <= "0000";
        wait for 300 ns;

        -- aperta botão 1
        buttons_tb <= "0010";
        wait for 40 ns;
        buttons_tb <= "0000";
        wait for 300 ns;

        -- aperta botão errado  (exemplo)
        buttons_tb <= "1000";
        wait for 40 ns;
        buttons_tb <= "0000";
        wait for 300 ns;

        -- encerra simulação
        wait for 2 us;
        assert false report "Fim da simulação." severity failure;

    end process;

end architecture;