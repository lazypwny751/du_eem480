-- Kütüphaneler
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity: Debouncing Devresi
-- Giriş sinyalinin 30ms boyunca istikrarlı kaldığında çıkışı güncelleme
entity db_fsm is
 port (
  clk, reset: in std_logic;      -- Saat ve reset sinyalleri
  sw: in std_logic;              -- Tuş/Switch giriş sinyali
  db: out std_logic              -- Debounce çıkış sinyali
 );
end db_fsm;

architecture arch of db_fsm is
 constant N: integer:=19; -- 2^N * 20ns = 10ms
 signal q_reg, q_next: unsigned(N-1 downto 0);
 signal m_tick: std_logic;
 type eg_state_type is (zero, wait1_1, wait1_2, wait1_3, one, wait0_1, wait0_2, wait0_3);
 signal state_reg, state_next: eg_state_type;
begin
 -- Sayıcı: 10ms zaman dilimi oluşturma (2^19 * 20ns)
 process(clk,reset)
 begin
 if (clk'event and clk='1') then
 q_reg <= q_next;
 end if;
 end process;
 -- Sayıcının sonraki durumu
 q_next <= q_reg + 1;
 -- 10ms tick sinyali çıkışı
 m_tick <= '1' when q_reg=0 else '0';

 -- Debouncing Sonlu Durum Makinesi (FSM)
 -- Durum kaydedici
 process(clk,reset)
 begin
 if (reset='1') then
 state_reg <= zero;
 elsif (clk'event and clk='1') then
 state_reg <= state_next;
 end if;
 end process;
 -- Sonraki durum ve çıkış mantığı
 process(state_reg,sw,m_tick)
 begin
 state_next <= state_reg; -- Varsayılan: aynı duruma geri dön
 db <= '0'; -- Varsayılan çıkış 0
 case state_reg is
 -- Durumu: Tuş basılmamış (0)
 when zero =>
 if sw='1' then
 state_next <= wait1_1;
 end if;
 -- Bekle 1. aşama: Tuş basılı kalıyor mu? (1. tick)
 when wait1_1 =>
 if sw='0' then
 state_next <= zero;
 else
 if m_tick='1' then
 state_next <= wait1_2;
 end if;
 end if;
 -- Bekle 1. aşama: Tuş basılı kalıyor mu? (2. tick)
 when wait1_2 =>
 if sw='0' then
 state_next <= zero;
 else
 if m_tick='1' then
 state_next <= wait1_3;
 end if;
 end if;
 -- Bekle 1. aşama: Tuş basılı kalıyor mu? (3. tick - tıklamada kararda)
 when wait1_3 =>
 if sw='0' then
 state_next <= zero;
 else
 if m_tick='1' then
 state_next <= one;
 end if;
 end if;
 -- Durumu: Tuş basıldı (1)
 when one =>
 db <= '1';
 if sw='0' then
 state_next <= wait0_1;
 end if;
 -- Bekle 0. aşama: Tuş bırakıldı mı? (1. tick)
 when wait0_1 =>
 db <= '1';
 if sw='1' then
 state_next <= one;
 else
 if m_tick='1' then
 state_next <= wait0_2;
 end if;
 end if;
 -- Bekle 0. aşama: Tuş bırakıldı mı? (2. tick)
 when wait0_2 =>
 db <= '1';
 if sw='1' then
 state_next <= one;
 else
 if m_tick='1' then
 state_next <= wait0_3;
 end if;
 end if;
 -- Bekle 0. aşama: Tuş bırakıldı mı? (3. tick - bırakışta kararda)
 when wait0_3 =>
 db <= '1';
 if sw='1' then
 state_next <= one;
 else
 if m_tick='1' then
 state_next <= zero;
 end if;
 end if;
 end case;
 end process;
end arch;
