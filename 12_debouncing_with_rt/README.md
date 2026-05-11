# Debounce Devresi

Butonlardaki fiziksel sekme (bouncing) ve gürültü problemlerini filtreleyen VHDL devresi. 
Kısa/uzun süreli basma ve bırakma gibi durumları simüle etmek için testbench hazırladık. FSMD yapısı kullanıldı.

## Dosyalar
- `db_rt.vhdl`: Ana tasarım (FSM & Sayaç kontrolü)
- `db_rt_tb.vhdl`: 4 farklı durumu deneyen testbench
- `xsim.sh`: GHDL simülasyonunu çalıştırıp GTKWave açan shell script'i

## Nasıl Çalıştırılır?
Linux ortamında GHDL ve GTKWave kuruluysa şu komutla doğrudan çalıştırıp dalgalara bakabilirsiniz:

```bash
./xsim.sh --view
```
