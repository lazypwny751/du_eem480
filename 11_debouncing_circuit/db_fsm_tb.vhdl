-- ============================================================================
-- Test Bench: Debouncing Devresi (db_fsm) - Simülasyon Test Dosyası
-- ============================================================================
-- Amaç: db_fsm bileşenini test etmek ve debouncing işlemini doğrulamak
-- Testler: Basılı/bırakılı, titreşim yoksayma, hızlı geçişler
-- ============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ============================================================================
-- Entity: db_fsm_tb (Test Bench)
-- ============================================================================
entity db_fsm_tb is
end db_fsm_tb;

-- ============================================================================
-- Mimari: Simülasyon Testi
-- ============================================================================
architecture tb of db_fsm_tb is

  -- ========================================================================
  -- Bileşen Bildirimi (Component Declaration)
  -- ========================================================================
  component db_fsm is
    port (
      clk   : in  std_logic;
      reset : in  std_logic;
      sw    : in  std_logic;
      db    : out std_logic
    );
  end component;

  -- ========================================================================
  -- Test Sinyalleri (Signals)
  -- ========================================================================
  signal clk_tb      : std_logic;
  signal reset_tb    : std_logic;
  signal sw_tb       : std_logic;
  signal db_tb       : std_logic;

  -- Saat periyodu: 20ns (50 MHz)
  constant CLK_PERIOD : time := 20 ns;

begin

  -- ========================================================================
  -- UUT (Unit Under Test): db_fsm Bileşenini Örneği Oluştur
  -- ========================================================================
  uut : db_fsm
    port map (
      clk   => clk_tb,
      reset => reset_tb,
      sw    => sw_tb,
      db    => db_tb
    );

  -- ========================================================================
  -- BLOK 1: Saat Üreticisi (Clock Generator)
  -- ========================================================================
  -- Açıklama: 50 MHz sistemik saat sinyali üret (20ns periyot)
  -- ========================================================================
  process
  begin
    clk_tb <= '0';
    wait for CLK_PERIOD / 2;
    clk_tb <= '1';
    wait for CLK_PERIOD / 2;
  end process;

  -- ========================================================================
  -- BLOK 2: Test Uyarıları (Test Stimulus)
  -- ========================================================================
  -- Açıklama: Çeşitli tuş basılı/bırakılı senaryolarını test et
  -- ========================================================================
  process
  begin
    -- ====================================================================
    -- BAŞLANGIÇ DURUMU
    -- ====================================================================
    report "========================================";
    report "Debouncing Devresi Test Başlıyor";
    report "========================================";

    -- Reset sinyali aktif et (100ns)
    reset_tb <= '1';
    sw_tb <= '0';
    wait for 100 ns;

    -- Reset sinyali pasif et
    reset_tb <= '0';
    wait for 100 ns;

    report "Başlangıç: Reset tamamlandı, sistem hazır";

    -- ====================================================================
    -- TEST 1: Basit Tuş Basılı/Bırakılı
    -- ====================================================================
    report "";
    report "TEST 1: Basit Tuş Basılı Sinyali (40ms)";
    report "Beklenen: Çıkış db 30ms gecikmeli olarak aktif olmalı";
    report "-------------------------------------------";

    sw_tb <= '1';  -- Tuşu bas
    wait for 40 ms;

    assert db_tb = '1'
      report "HATA: db çıkışı 40ms sonra '1' olmalı!" severity error;

    report "TEST 1 BAŞARILI: db çıkışı aktif";

    -- ====================================================================
    -- TEST 2: Tuş Bırakılması
    -- ====================================================================
    report "";
    report "TEST 2: Tuş Bırakılması (40ms)";
    report "Beklenen: Çıkış db 30ms gecikmeli olarak pasif olmalı";
    report "-------------------------------------------";

    sw_tb <= '0';  -- Tuşu bırak
    wait for 40 ms;

    assert db_tb = '0'
      report "HATA: db çıkışı 40ms sonra '0' olmalı!" severity error;

    report "TEST 2 BAŞARILI: db çıkışı pasif";

    -- ====================================================================
    -- TEST 3: Kısa Titreşim Testi (Debounce Yoksayma)
    -- ====================================================================
    report "";
    report "TEST 3: Kısa Titreşim Testi (5ms pulse'lar)";
    report "Beklenen: Kısa pulse'lar debounce tarafından yoksayılmalı";
    report "-------------------------------------------";

    -- Üç tane hızlı pulse gönder (her biri 5ms)
    sw_tb <= '1';
    wait for 5 ms;

    sw_tb <= '0';
    wait for 5 ms;

    sw_tb <= '1';
    wait for 5 ms;

    sw_tb <= '0';
    wait for 5 ms;

    -- Bu noktada titreşim henüz yoksayılmış olmalı
    assert db_tb = '0'
      report "HATA: Kısa pulse'lar debounce tarafından yoksayılmalı!" severity error;

    report "TEST 3 BAŞARILI: Titreşim yoksayıldı";

    -- ====================================================================
    -- TEST 4: Tekrarlayan Tuş Basışı (3 kere)
    -- ====================================================================
    report "";
    report "TEST 4: Tekrarlayan Tuş Basışı (50ms aralıklar)";
    report "Beklenen: Her basılı/bırakılı çiftinde 30ms gecikmeli yanıt";
    report "-------------------------------------------";

    for i in 1 to 3 loop
      report "  Döngü " & integer'image(i) & ": Tuş basıl";
      sw_tb <= '1';
      wait for 50 ms;

      assert db_tb = '1'
        report "HATA: db çıkışı döngü " & integer'image(i) & " basılı sırasında '1' olmalı!" 
        severity error;

      report "  Döngü " & integer'image(i) & ": Tuş bırak";
      sw_tb <= '0';
      wait for 50 ms;

      assert db_tb = '0'
        report "HATA: db çıkışı döngü " & integer'image(i) & " bırakılı sırasında '0' olmalı!" 
        severity error;

      report "  Döngü " & integer'image(i) & " BAŞARILI";
    end loop;

    report "TEST 4 BAŞARILI: Tekrarlayan tuş testleri geçildi";

    -- ====================================================================
    -- SONUÇ
    -- ====================================================================
    report "";
    report "========================================";
    report "TÜM TESTLER BAŞARILI!";
    report "Debouncing Devresi Doğru Çalışıyor";
    report "========================================";

    wait;

  end process;

end tb;
