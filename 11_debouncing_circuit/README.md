# Debouncing Devresi (db_fsm) - VHDL Uygulaması

## Genel Bakış

Bu proje, bir tuş/switch giriş sinyalinin mekanik titreşim (bounce) etkilerini gidermek için tasarlanmış bir **Sonlu Durum Makinesi (FSM)** uygulamasıdır.

## Dosyalar

### db_fsm.vhdl
Ana debouncing devresi dosyası. Aşağıdakileri içerir:
- **10ms Zaman Dilimi Sayıcısı**: 2^19 * 20ns = 10ms
- **Sonlu Durum Makinesi**: 8 durum (zero, wait1_1, wait1_2, wait1_3, one, wait0_1, wait0_2, wait0_3)
- **Girdiler**: clk (saat), reset (sıfırlama), sw (tuş/switch)
- **Çıktı**: db (debounce edilmiş sinyal)

### db_fsm_tb.vhdl
Test bench dosyası. Devreyi simüle eder:
- Basit tuş basılı/bırakılı testleri
- Kısa titreşim testleri
- Tekrarlayan basılı/bırakılı testleri

## Çalışma Prensibi

Debouncing işlemi şöyle çalışır:

1. **Tuş Basılırsa (zero → wait1_1 → wait1_2 → wait1_3 → one)**
   - Tuş basıldığında wait1_1 durumuna geçilir
   - 30ms boyunca (3 × 10ms) tuş basılı kalıp kalmadığı kontrol edilir
   - 30ms boyunca basılı kalırsa "one" durumuna geçilir (debounce tamamlandı)

2. **Tuş Bırakılırsa (one → wait0_1 → wait0_2 → wait0_3 → zero)**
   - Tuş bırakıldığında wait0_1 durumuna geçilir
   - 30ms boyunca tuş açık kalıp kalmadığı kontrol edilir
   - 30ms boyunca açık kalırsa "zero" durumuna döner (debounce tamamlandı)

3. **Titreşim Yoksayma**
   - 30ms'den kısa süreli değişiklikler görmezden gelinir
   - Mekanik titreşimin etkisi ortadan kaldırılır

## Port Tanımları

| Port | Yön | Açıklama |
|------|-----|----------|
| clk | Giriş | 50 MHz sistem saati (20ns periyot) |
| reset | Giriş | Aktif yüksek reset sinyali |
| sw | Giriş | Tuş/Switch giriş sinyali |
| db | Çıkış | Debounce edilmiş çıkış sinyali |

## Zaman Parametreleri

- **Saat Periyodu**: 20ns (50 MHz)
- **Sabit N**: 19 (2^19 = 524.288 tick)
- **Zaman Dilimi**: 2^19 × 20ns ≈ 10.48ms ≈ 10ms
- **Debounce Süresi**: 3 × 10ms = 30ms

## Simülasyon

### xsim.sh Script'i ile (Önerilir)

En kolay yol, sağlanan otomatik simülasyon script'ini kullanmaktır:

```bash
# Script'i çalıştırılabilir yap
chmod +x xsim.sh

# Varsayılan 1us süre ile çalıştır
./xsim.sh

# 200ms süre ile çalıştır (debouncing için önerilir)
./xsim.sh --time 200ms

# Simülasyon sonrası GTKWave'de dalga formlarını aç
./xsim.sh --time 200ms --view

# Yardım
./xsim.sh --help
```

**Script ne yapar?**
- Eski derleme dosyalarını temizler (`*.cf`, `*.vcd`)
- VHDL kaynak dosyalarını analiz eder (Analyze)
- Testbench'i derler (Elaborate)
- Simülasyonu çalıştırır ve VCD dosyası oluşturur (Simulate)
- İsteğe bağlı olarak GTKWave'de açılabilir

### Manuel GHDL Komutları

Alternatif olarak, adım adım manuel olarak:

```bash
# Adım 1: Kaynak dosyalarını analiz et
ghdl -a --std=08 db_fsm.vhdl db_fsm_tb.vhdl

# Adım 2: Testbench'i elaborate et
ghdl -e --std=08 db_fsm_tb

# Adım 3: Simülasyonu çalıştır (1ms için)
ghdl -r --std=08 db_fsm_tb --stop-time=1ms --vcd=db_fsm_tb.vcd

# Adım 4: GTKWave'de aç
gtkwave db_fsm_tb.vcd
```

## Notlar

- Tüm sinyaller aktif yüksek (logic '1' = aktif)
- Reset sırasında devre "zero" durumuna ayarlanır
- FSM tamamen senkron (clk'e bağlı) çalışır
