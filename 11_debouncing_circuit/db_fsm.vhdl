-- ============================================================================
-- Debouncing Devresi - VHDL Uygulaması
-- ============================================================================
-- Amaç: Tuş/Switch giriş sinyalinin mekanik titreşim etkisini gidermek
-- Zaman Dilimi: 10ms (2^19 * 20ns) x3 = 30ms debounce süresi
-- ============================================================================

-- ============================================================================
-- Kütüphaneler
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ============================================================================
-- Entity: Debouncing Devresi (db_fsm)
-- ============================================================================
-- Giriş sinyalinin 30ms boyunca istikrarlı kaldığında çıkışı güncelleme
entity db_fsm is
  port (
    clk       : in  std_logic;   -- Sistem saati (50 MHz)
    reset     : in  std_logic;   -- Asenkron reset (aktif yüksek)
    sw        : in  std_logic;   -- Tuş/Switch giriş sinyali
    db        : out std_logic    -- Debounce edilmiş çıkış sinyali
  );
end db_fsm;

-- ============================================================================
-- Mimari: FSM Tabanlı Debouncing Devresi
-- ============================================================================
architecture arch of db_fsm is

  -- ========================================================================
  -- Sabitler ve Sinyaller
  -- ========================================================================
  constant N : integer := 19;  -- 2^N * 20ns = 10ms zaman dilimi

  -- Sayıcı sinyalleri (10ms tick oluşturmak için)
  signal q_reg, q_next : unsigned(N-1 downto 0);
  signal m_tick        : std_logic;

  -- FSM durum tanımı (8 durum: 0 veya 1 ile 30ms geçiş süresi)
  type eg_state_type is (
    zero,      -- Tuş basılmamış (stabil durumu)
    wait1_1,   -- Bekle durum 1/3: 10ms
    wait1_2,   -- Bekle durum 2/3: 20ms
    wait1_3,   -- Bekle durum 3/3: 30ms (sonra "one"'a geç)
    one,       -- Tuş basıldı (stabil durumu)
    wait0_1,   -- Bekle durum 1/3: 10ms
    wait0_2,   -- Bekle durum 2/3: 20ms
    wait0_3    -- Bekle durum 3/3: 30ms (sonra "zero"'a geç)
  );

  signal state_reg, state_next : eg_state_type;

begin

  -- ==========================================================================
  -- BLOK 1: 10ms Zaman Dilimi Sayıcısı
  -- ==========================================================================
  -- Amaç: Her 10ms'de bir tick sinyali üret
  -- Sayıcı, 2^19 tick sayıldığında reset olur
  -- ==========================================================================

  -- Sayıcı kaydedici (clk yükselen kenarında güncelle)
  process (clk, reset)
  begin
    if (reset = '1') then
      q_reg <= (others => '0');
    elsif (clk'event and clk = '1') then
      q_reg <= q_next;
    end if;
  end process;

  -- Sayıcı mantığı: sayı sıfırdan başlayarak artır, max'a ulaşınca sıfırla
  q_next <= (others => '0') when (q_reg = (2**N - 1)) else (q_reg + 1);

  -- Tick sinyali: Sayıcı sıfırda olduğunda high
  m_tick <= '1' when (q_reg = 0) else '0';

  -- ==========================================================================
  -- BLOK 2: Durum Makinesi (FSM) - Debouncing Mantığı
  -- ==========================================================================
  -- Amaç: Tuş sinyalini 30ms boyunca stabil olması koşuluyla izlemek
  -- Stabil durumda: 0 (basılmamış) veya 1 (basıldı)
  -- Geçiş durumları: wait1_1, wait1_2, wait1_3 (0->1) ve wait0_1, wait0_2, wait0_3 (1->0)
  -- ==========================================================================

  -- Durum kaydedici (clk yükselen kenarında güncelle)
  process (clk, reset)
  begin
    if (reset = '1') then
      state_reg <= zero;  -- Başlangıçta tuş basılmamış
    elsif (clk'event and clk = '1') then
      state_reg <= state_next;
    end if;
  end process;

  -- Durum geçiş ve çıkış mantığı
  process (state_reg, sw, m_tick)
  begin
    -- Varsayılan değerler
    state_next <= state_reg;  -- Durumda kal
    db <= '0';                -- Çıkış 0

    case state_reg is

      -- ====================================================================
      -- DURUM: ZERO (Tuş Basılmamış - Stabil)
      -- ====================================================================
      when zero =>
        db <= '0';
        if (sw = '1') then
          -- Tuş basıldı! Geçiş durumuna git
          state_next <= wait1_1;
        end if;

      -- ====================================================================
      -- DURUM: WAIT1_1 (Tuş Basılı Geçiş - 1/3: 10ms)
      -- ====================================================================
      when wait1_1 =>
        if (sw = '0') then
          -- Tuş bırakıldı, geri dön (titreşim yoksayıldı)
          state_next <= zero;
        elsif (m_tick = '1') then
          -- 10ms geçti, ikinci aşamaya git
          state_next <= wait1_2;
        end if;

      -- ====================================================================
      -- DURUM: WAIT1_2 (Tuş Basılı Geçiş - 2/3: 20ms)
      -- ====================================================================
      when wait1_2 =>
        if (sw = '0') then
          -- Tuş bırakıldı, geri dön (titreşim yoksayıldı)
          state_next <= zero;
        elsif (m_tick = '1') then
          -- 20ms geçti, üçüncü aşamaya git
          state_next <= wait1_3;
        end if;

      -- ====================================================================
      -- DURUM: WAIT1_3 (Tuş Basılı Geçiş - 3/3: 30ms - Final Kontrol)
      -- ====================================================================
      when wait1_3 =>
        if (sw = '0') then
          -- Tuş bırakıldı, geri dön (titreşim yoksayıldı)
          state_next <= zero;
        elsif (m_tick = '1') then
          -- 30ms boyunca stabil kaldı! Debounce tamam
          state_next <= one;
        end if;

      -- ====================================================================
      -- DURUM: ONE (Tuş Basıldı - Stabil)
      -- ====================================================================
      when one =>
        db <= '1';  -- Çıkış high
        if (sw = '0') then
          -- Tuş bırakıldı! Geçiş durumuna git
          state_next <= wait0_1;
        end if;

      -- ====================================================================
      -- DURUM: WAIT0_1 (Tuş Bırakılı Geçiş - 1/3: 10ms)
      -- ====================================================================
      when wait0_1 =>
        db <= '1';  -- Henüz çıkış high (debounce için)
        if (sw = '1') then
          -- Tuş basıldı, geri dön (titreşim yoksayıldı)
          state_next <= one;
        elsif (m_tick = '1') then
          -- 10ms geçti, ikinci aşamaya git
          state_next <= wait0_2;
        end if;

      -- ====================================================================
      -- DURUM: WAIT0_2 (Tuş Bırakılı Geçiş - 2/3: 20ms)
      -- ====================================================================
      when wait0_2 =>
        db <= '1';  -- Henüz çıkış high (debounce için)
        if (sw = '1') then
          -- Tuş basıldı, geri dön (titreşim yoksayıldı)
          state_next <= one;
        elsif (m_tick = '1') then
          -- 20ms geçti, üçüncü aşamaya git
          state_next <= wait0_3;
        end if;

      -- ====================================================================
      -- DURUM: WAIT0_3 (Tuş Bırakılı Geçiş - 3/3: 30ms - Final Kontrol)
      -- ====================================================================
      when wait0_3 =>
        db <= '1';  -- Henüz çıkış high (debounce için)
        if (sw = '1') then
          -- Tuş basıldı, geri dön (titreşim yoksayıldı)
          state_next <= one;
        elsif (m_tick = '1') then
          -- 30ms boyunca stabil kaldı! Debounce tamam
          state_next <= zero;
        end if;

    end case;
  end process;

end arch;
