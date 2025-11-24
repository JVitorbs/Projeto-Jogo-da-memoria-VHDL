library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
    port(
        clk        : in  std_logic;
        reset      : in  std_logic;
        match_flag : in  std_logic;  -- datapath informa se o último botão bateu
        end_flag   : in  std_logic;  -- datapath informa fim da sequência (mostrada)

        seq_load   : out std_logic;  -- pedir que datapath grave novo passo (usa rnd)
        seq_next   : out std_logic;  -- pedir que datapath avance índice de exibição
        seq_cmp    : out std_logic;  -- pedir que datapath confirme/avance play_idx
        rnd_en     : out std_logic   -- habilita LFSR (gera novo rnd)
    );
end entity;

architecture fsm of controller is
    type state_t is (IDLE, GEN, SHOW, WAIT_BTN, CHECK, ERROR, SUCCESS);
    signal st : state_t := IDLE;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            st <= IDLE;
        elsif rising_edge(clk) then
            case st is
                when IDLE =>
                    -- espera começo automático: no seu projeto você pode usar um botão start.
                    -- Aqui, por simplicidade, passa direto para GEN quando reset sai
                    st <= GEN;

                when GEN =>
                    -- pede geração (LFSR) e armazenamento do novo passo
                    st <= SHOW;

                when SHOW =>
                    -- espera que datapath sinalize que terminou mostrar (end_flag)
                    if end_flag = '1' then
                        st <= WAIT_BTN;
                    else
                        st <= SHOW;
                    end if;

                when WAIT_BTN =>
                    -- espera o jogador apertar (datapath faz btn_pressed visible)
                    -- a transição para CHECK é comandada externamente: usamos seq_cmp handshake.
                    -- Simples: quando match_flag = 'X' não indica press; so move para CHECK por seq_cmp.
                    -- Para manter simples: vamos ir direto ao CHECK quando match_flag /= 'Z' ...
                    st <= CHECK;

                when CHECK =>
                    if match_flag = '1' then
                        -- jogador acertou; se quiser, volte a GEN para acrescentar outro passo
                        st <= GEN;
                    else
                        st <= ERROR;
                    end if;

                when ERROR =>
                    -- fica aqui até reset (poderia esperar botão start)
                    st <= ERROR;

                when SUCCESS =>
                    st <= SUCCESS;

            end case;
        end if;
    end process;

    -- saídas simples baseadas no estado (one-hot like)
    seq_load <= '1' when st = GEN else '0';
    seq_next <= '1' when st = SHOW else '0';
    seq_cmp  <= '1' when st = CHECK else '0';
    rnd_en   <= '1' when st = GEN else '0';

end architecture;