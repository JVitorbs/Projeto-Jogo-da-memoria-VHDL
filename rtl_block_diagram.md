# Projeto RTL - Memory Game (Simon-like)

```mermaid
flowchart LR
    %% Input Ports
    subgraph INPUTS[" "]
        CLK((clk))
        RST((reset_n))
        START((start_btn))
        BTN(("buttons[3:0]"))
    end
    
    %% Processing Units
    subgraph PU[Processing Units]
        direction TB
        
        subgraph CLK_GEN[Clock Generation]
            CLKDIV[clk_divider<br/>24-bit counter<br/>÷2^20]
        end
        
        subgraph RNG[Random Number Gen]
            LFSR[lfsr_8bit<br/>x^8+x^6+x^5+x^4+1<br/>2-bit output]
        end
        
        subgraph BTN_CTRL[Button Interface]
            DEBOUNCE[debounce<br/>edge_detect<br/>encoder_4to2]
        end
    end
    
    %% Main Processing Core
    subgraph CORE[Main Processing Core]
        direction TB
        
        subgraph CONTROLLER[Controller]
            FSM[controller_fsm<br/>7 states<br/>Moore machine]
        end
        
        subgraph DATAPATH[Datapath]
            MEM[seq_memory<br/>8x2 RAM]
            COUNTERS["counters<br/>step_cnt[3:0]<br/>show_idx[3:0]<br/>play_idx[3:0]"]
            ALU[comparator<br/>match_logic<br/>index_mux]
            TIMER[display_timer<br/>16-bit counter]
        end
    end
    
    %% Output Ports
    subgraph OUTPUTS[" "]
        LEDS(("leds[3:0]"))
        OVER((game_over))
        WIN((win))
    end
    
    %% Control/Data Buses
    CLK -.->|clk| PU
    CLK -.->|clk| CORE
    RST -.->|rst_n| PU
    RST -.->|rst_n| CORE
    
    START -->|start_btn| FSM
    BTN -->|"btn[3:0]"| BTN_CTRL
    
    CLKDIV -->|clk_slow| DATAPATH
    RNG -->|"rnd[1:0]"| DATAPATH
    BTN_CTRL -->|"btn_edge[3:0]<br/>btn_idx[1:0]"| DATAPATH
    BTN_CTRL -->|btn_pressed| FSM
    
    FSM <-->|ctrl_signals<br/>status_flags| DATAPATH
    
    DATAPATH -->|"led_data[3:0]"| LEDS
    FSM -->|error_flag| OVER
    FSM -->|success_flag| WIN
```

## RTL Architecture Overview

### Processing Units
| Module | Function | Implementation |
|--------|----------|----------------|
| clk_divider | Clock generation | 24-bit counter, ÷2^20 |
| lfsr_8bit | Random generation | 8-bit LFSR, polynomial x^8+x^6+x^5+x^4+1 |
| debounce | Button interface | Edge detect + 4:2 encoder |

### Controller FSM
- **Type**: Moore machine, 7 states
- **States**: IDLE → GEN → SHOW → WAIT → CHECK → ERROR/WIN
- **Outputs**: Control signals (seq_load, seq_next, seq_cmp)

### Datapath Components
| Component | Size | Function |
|-----------|------|----------|
| seq_memory | 8×2 RAM | Sequence storage |
| step_cnt | 4-bit counter | Current sequence length |
| show_idx | 4-bit counter | Display index |
| play_idx | 4-bit counter | Player input index |
| comparator | Combinational | Match detection logic |
| display_timer | 16-bit counter | LED timing control |

### Control/Status Signals
- **Control Bus**: seq_load, seq_next, seq_cmp, rnd_en
- **Status Bus**: match_flag, end_flag, btn_pressed
- **Data Bus**: rnd[1:0], btn_idx[1:0], led_data[3:0]