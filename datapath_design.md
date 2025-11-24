# Projeto do Caminho de Dados - Jogo da Memória

## Diagrama do Datapath

```mermaid
flowchart TD
    %% Inputs
    CLK[clk]
    CLK_SLOW[clk_slow]
    RST[reset]
    RND[rnd_bit 2b]
    BTN[button_i 4b]
    
    %% Control Signals
    SEQ_LOAD[seq_load]
    SEQ_NEXT[seq_next]
    SEQ_CMP[seq_cmp]
    
    %% Memory Elements
    SEQ_MEM[Sequence Memory<br/>8x2 bits]
    STEP_CNT[step_count<br/>0 to 8]
    SHOW_IDX[show_idx<br/>0 to 8]
    PLAY_IDX[play_idx<br/>0 to 8]
    
    %% Logic Blocks
    BTN_DET[Button Edge<br/>Detector]
    CMP[Comparator]
    LED_MUX[LED Mux]
    
    %% Outputs
    LEDS[leds_o 4b]
    MATCH[match_flag]
    END_F[end_flag]
    
    %% Connections
    CLK --> SEQ_MEM
    CLK --> STEP_CNT
    CLK --> SHOW_IDX
    CLK --> PLAY_IDX
    CLK --> BTN_DET
    
    RST --> SEQ_MEM
    RST --> STEP_CNT
    RST --> SHOW_IDX
    RST --> PLAY_IDX
    
    RND --> SEQ_MEM
    SEQ_LOAD --> SEQ_MEM
    SEQ_LOAD --> STEP_CNT
    
    CLK_SLOW --> LED_MUX
    SEQ_NEXT --> LED_MUX
    SEQ_MEM --> LED_MUX
    SHOW_IDX --> LED_MUX
    LED_MUX --> LEDS
    
    BTN --> BTN_DET
    BTN_DET --> CMP
    SEQ_MEM --> CMP
    PLAY_IDX --> CMP
    CMP --> MATCH
    
    SEQ_CMP --> PLAY_IDX
    SHOW_IDX --> END_F
    STEP_CNT --> END_F
```

## Componentes Principais

### Memória da Sequência
- **Tipo**: Array 8x2 bits
- **Função**: Armazena sequência de LEDs
- **Controle**: seq_load para escrita

### Contadores
- **step_count**: Número de passos na sequência atual
- **show_idx**: Índice para exibição da sequência  
- **play_idx**: Índice para verificação do jogador

### Detector de Botões
- **Entrada**: button_i[3:0] (debounced)
- **Função**: Detecta borda de subida
- **Saída**: Índice do botão pressionado

### Comparador
- **Função**: Compara botão vs sequência esperada
- **Saída**: match_flag

### Multiplexador de LEDs
- **Função**: Seleciona LED ativo durante SHOW
- **Controle**: clk_slow + seq_next

## Sinais de Dados

| Sinal | Largura | Função |
|-------|---------|---------|
| sequence | 8x2 bits | Array da sequência |
| step_count | 4 bits | Contador de passos |
| show_idx | 4 bits | Índice de exibição |
| play_idx | 4 bits | Índice do jogador |
| pressed_idx | 2 bits | Botão pressionado |
| leds_reg | 4 bits | Registro dos LEDs |