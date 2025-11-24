# Projeto do Caminho de Dados - Jogo da Memória

## Diagrama do Datapath

```mermaid
flowchart TB
    %% Input Ports
    subgraph IN["🔌 INPUT PORTS"]
        direction LR
        CLK["⏰ clk"]
        RST["🔄 reset"]
        RND["🎲 rnd[1:0]"]
        BTN["🔘 btn[3:0]"]
        SLOW["⏱️ clk_slow"]
    end
    
    %% Control Interface
    subgraph CTRL["⚡ CONTROL INTERFACE"]
        direction LR
        LOAD{"seq_load"}
        NEXT{"seq_next"}
        CMP_EN{"seq_cmp"}
    end
    
    %% Memory Subsystem
    subgraph MEM["💾 MEMORY SUBSYSTEM"]
        direction TB
        SEQ["📦 Sequence Memory<br/>8×2 RAM<br/>16 bits total"]
        SCNT["🔢 Step Counter<br/>4-bit up counter<br/>range: 0-8"]
        SIDX["👁️ Show Index<br/>4-bit counter<br/>display pointer"]
        PIDX["🎮 Play Index<br/>4-bit counter<br/>input pointer"]
    end
    
    %% Processing Engine
    subgraph PROC["⚙️ PROCESSING ENGINE"]
        direction TB
        EDGE["📈 Edge Detector<br/>4-channel<br/>rising edge"]
        CMP["⚖️ Comparator<br/>2-bit equality<br/>match logic"]
        MUX["🔀 LED Multiplexer<br/>4:1 selector<br/>one-hot output"]
        TMR["⏲️ Display Timer<br/>16-bit counter<br/>LED timing"]
    end
    
    %% Output Ports
    subgraph OUT["📤 OUTPUT PORTS"]
        direction LR
        LEDS["💡 leds[3:0]"]
        MATCH["✅ match_flag"]
        END_F["🏁 end_flag"]
    end
    
    %% Clock Tree (dotted lines)
    CLK -.->|"🕐 system clock"| MEM
    CLK -.->|"🕐 system clock"| PROC
    RST -.->|"🔄 async reset"| MEM
    RST -.->|"🔄 async reset"| PROC
    
    %% Data Paths (thick lines)
    RND ==>|"random data"| SEQ
    BTN ==>|"button inputs"| EDGE
    SLOW ==>|"slow clock"| TMR
    
    %% Control Paths (normal lines)
    LOAD --> SEQ
    LOAD --> SCNT
    NEXT --> MUX
    CMP_EN --> PIDX
    
    %% Internal Data Flow
    SEQ --> MUX
    SEQ --> CMP
    SIDX --> MUX
    PIDX --> CMP
    EDGE --> CMP
    TMR --> MUX
    
    %% Output Connections
    MUX ==>|"LED data"| LEDS
    CMP ==>|"comparison result"| MATCH
    SIDX ==>|"sequence complete"| END_F
    
    %% Styling
    classDef inputStyle fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef memStyle fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef procStyle fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px
    classDef outputStyle fill:#fff3e0,stroke:#e65100,stroke-width:2px
    classDef ctrlStyle fill:#fce4ec,stroke:#880e4f,stroke-width:2px
    
    class CLK,RST,RND,BTN,SLOW inputStyle
    class SEQ,SCNT,SIDX,PIDX memStyle
    class EDGE,CMP,MUX,TMR procStyle
    class LEDS,MATCH,END_F outputStyle
    class LOAD,NEXT,CMP_EN ctrlStyle
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