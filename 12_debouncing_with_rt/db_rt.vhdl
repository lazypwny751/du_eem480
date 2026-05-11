library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce is
    port(
        clk      : in  std_logic;
        reset    : in  std_logic;
        sw       : in  std_logic;
        db_level : out std_logic;
        db_tick  : out std_logic
    );
end debounce;

architecture exp_fsmd_arch of debounce is
    -- 2^N * 20ns = 40ms filtreleme süresi
    -- Not: Simülasyonu hızlı yapabilmek için tb dosyasında clk kısa tutulabilir veya
    -- N degeri kücültülebilir. Ancak bu örnekte N degeri 3 olarak küçültülmüştür (simülasyon için),
    -- orijinali ise 21'di.
    constant N : integer := 3; 

    -- FSMD (Finite State Machine with Datapath) durumları
    type state_type is (zero, wait0, one, wait1);
    
    -- Durum kayıtları
    signal state_reg  : state_type;
    signal state_next : state_type;
    
    -- Veriyolu sayacı kayıtları
    signal q_reg   : unsigned(N-1 downto 0);
    signal q_next  : unsigned(N-1 downto 0);
    
    -- Veriyolu kontrol sinyalleri
    signal q_load : std_logic;
    signal q_dec  : std_logic;
    signal q_zero : std_logic;
begin
    ---------------------------------------------------------------------------
    -- Durum ve Veri Kayıtları (State & Data Registers)
    ---------------------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            state_reg <= zero;
            q_reg <= (others => '0');
        elsif rising_edge(clk) then
            state_reg <= state_next;
            q_reg <= q_next;
        end if;
    end process;
    
    ---------------------------------------------------------------------------
    -- Veriyolu (Datapath): Sonraki Durum Mantığı (Sayaç / Counter)
    ---------------------------------------------------------------------------
    q_next <= (others => '1') when q_load = '1' else -- Sayacı maksimum değere yükle
              q_reg - 1       when q_dec = '1'  else -- Sayacı 1 azalt
              q_reg;                                 -- Sayacı koru
              
    q_zero <= '1' when q_next = 0 else '0';
    
    ---------------------------------------------------------------------------
    -- Kontrol Yolu (Control Path): Sonraki Durum ve Çıkış Mantığı (FSM)
    ---------------------------------------------------------------------------
    process(state_reg, sw, q_zero)
    begin
        -- Varsayılan atamalar
        q_load     <= '0';
        q_dec      <= '0';
        db_tick    <= '0';
        state_next <= state_reg;
        
        case state_reg is
            -------------------------------------------------------------------
            -- ZERO Durumu: Giriş 0 olarak kabul edilmiş
            -------------------------------------------------------------------
            when zero =>
                db_level <= '0';
                if sw = '1' then
                    -- Butona basıldığını hissettik, bekleme durumuna geç ve sayacı yükle
                    state_next <= wait1;
                    q_load <= '1';
                end if;
                
            -------------------------------------------------------------------
            -- WAIT1 Durumu: Giriş 1'e geçti, stabil olmasını bekle
            -------------------------------------------------------------------
            when wait1 =>
                db_level <= '0';
                if sw = '1' then
                    q_dec <= '1'; -- Giriş hala 1 ise saymaya devam et
                    if q_zero = '1' then
                        -- Sayaç sıfırlandı, girişin kalıcı olarak 1 olduğuna emin olduk
                        state_next <= one;
                        db_tick <= '1';
                    end if;
                else
                    -- Giriş süre dolmadan 0'a döndü, bu bir gürültü!
                    state_next <= zero;
                end if;
                
            -------------------------------------------------------------------
            -- ONE Durumu: Giriş 1 olarak kabul edilmiş
            -------------------------------------------------------------------
            when one =>
                db_level <= '1';
                if sw = '0' then
                    -- Butondan çekildiğini hissettik, bekleme durumuna geç ve sayacı yükle
                    state_next <= wait0;
                    q_load <= '1';
                end if;
                
            -------------------------------------------------------------------
            -- WAIT0 Durumu: Giriş 0'a geçti, stabil olmasını bekle
            -------------------------------------------------------------------
            when wait0 =>
                db_level <= '1';
                if sw = '0' then
                    q_dec <= '1'; -- Giriş hala 0 ise saymaya devam et
                    if q_zero = '1' then
                        -- Sayaç sıfırlandı, girişin kalıcı olarak 0 olduğuna emin olduk
                        state_next <= zero;
                    end if;
                else
                    -- Giriş süre dolmadan 1'e döndü, bu bir gürültü!
                    state_next <= one;
                end if;
                
        end case;
    end process;
end exp_fsmd_arch;
