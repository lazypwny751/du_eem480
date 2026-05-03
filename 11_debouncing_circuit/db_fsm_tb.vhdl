-- Test Bench: Debouncing Devresi (db_fsm) Test Dosyası
-- Bu dosya debouncing devresi simülasyonunu sağlar

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity db_fsm_tb is
end db_fsm_tb;

architecture tb of db_fsm_tb is
 -- Bileşen bildirimi
 component db_fsm is
  port (
   clk, reset: in std_logic;
   sw: in std_logic;
   db: out std_logic
  );
 end component;
 
 -- Test sinyalleri
 signal clk_tb, reset_tb: std_logic;
 signal sw_tb: std_logic;
 signal db_tb: std_logic;
 constant CLK_PERIOD: time := 20 ns; -- 50 MHz saat
 
begin
 -- db_fsm bileşenini örneği
 uut: db_fsm port map (
  clk => clk_tb,
  reset => reset_tb,
  sw => sw_tb,
  db => db_tb
 );
 
 -- Saat üreteç
 process
 begin
  clk_tb <= '0';
  wait for CLK_PERIOD/2;
  clk_tb <= '1';
  wait for CLK_PERIOD/2;
 end process;
 
 -- Test uyarıları
 process
 begin
  -- Başlangıç durumu
  reset_tb <= '1';
  sw_tb <= '0';
  wait for 100 ns;
  
  reset_tb <= '0';
  wait for 100 ns;
  
  -- Test 1: Tuş basılı, 40ms boyunca (debounc edilecek)
  report "Test 1: Tus basili sinyali - debounce testi";
  sw_tb <= '1';
  wait for 40 ms;
  
  -- Test 2: Tuş bırakılı
  report "Test 2: Tus birakili sinyali - debounce testi";
  sw_tb <= '0';
  wait for 40 ms;
  
  -- Test 3: Kısa titreşim testi (debounce tarafından yoksayılacak)
  report "Test 3: Kisa titresim testi";
  sw_tb <= '1';
  wait for 5 ms;
  sw_tb <= '0';
  wait for 5 ms;
  sw_tb <= '1';
  wait for 5 ms;
  sw_tb <= '0';
  wait for 50 ms;
  
  -- Test 4: Tekrarlayan basılı/bırakılı
  report "Test 4: Tekrarlayan tus testi";
  for i in 1 to 3 loop
   sw_tb <= '1';
   wait for 50 ms;
   sw_tb <= '0';
   wait for 50 ms;
  end loop;
  
  -- Simülasyonu bitir
  report "Simülasyon tamamlandı";
  wait;
 end process;
 
end tb;
