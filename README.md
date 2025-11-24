Projeto: Jogo da Memória (Simon-like) - VHDL
Arquivos gerados:
- datapath.vhd
- top_memory_game_separated.vhd
- (dependências esperadas: controller_fsm.vhd, clk_divider.vhd, debounce.vhd, lfsr_rng.vhd)

Imagem do enunciado (upload do usuário):
/mnt/data/0570e123-2c9a-412a-a6b6-bd32f5ae050a.png

Instruções rápidas:
1. Abra o Quartus II 13.0sp1 e crie um novo projeto.
2. Adicione todos os arquivos VHDL: datapath.vhd, controller_fsm.vhd, clk_divider.vhd, debounce.vhd, lfsr_rng.vhd, top_memory_game_separated.vhd.
3. Configure o dispositivo (Assignment -> Device) para sua board.
4. Use Pin Planner para mapear sinais: clk, reset_n, leds[3:0], btn[3:0], start_btn.
5. Compile e programe a FPGA.
6. Para simulação, crie um testbench que instancie top_memory_game_separated.vhd e forneça estímulos.

Observações:
- Os arquivos aqui são um datapath didático. Ajuste tempos, detecção de borda e lógica de avanço de índice se quiser comportamento mais robusto.
- O README referencia a imagem original enviada pelo usuário (caminho local acima).