library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity db_rt_tb is
end db_rt_tb;

architecture behavior of db_rt_tb is
    -- Component Declaration for the Unit Under Test (UUT)
    component debounce
    port(
         clk      : in  std_logic;
         reset    : in  std_logic;
         sw       : in  std_logic;
         db_level : out std_logic;
         db_tick  : out std_logic
        );
    end component;

    -- Inputs
    signal clk   : std_logic := '0';
    signal reset : std_logic := '0';
    signal sw    : std_logic := '0';

    -- Outputs
    signal db_level : std_logic;
    signal db_tick  : std_logic;

    -- Clock period definitions
    constant clk_period : time := 20 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: debounce port map (
          clk      => clk,
          reset    => reset,
          sw       => sw,
          db_level => db_level,
          db_tick  => db_tick
        );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    -- Stimulus process
    stim_proc: process
    begin       
        -- 1. Başlangıç Durumu (Reset)
        reset <= '1';
        sw <= '0';
        wait for 40 ns;  
        reset <= '0';
        wait for 40 ns;

        ----------------------------------------------------
        -- Senaryo 1: Gürültü (Kısa Süreli Basma / Glitch)
        -- Butona çok kısa süre basıp bırakılıyor
        ----------------------------------------------------
        sw <= '1';
        wait for 60 ns; -- Debounce süresinden çok kısa (N=3 olduğu için 2^3 = 8 clock beklemezse kabul etmez)
        sw <= '0';
        wait for 100 ns;

        ----------------------------------------------------
        -- Senaryo 2: Başarılı Basma (Uzun Süreli)
        ----------------------------------------------------
        sw <= '1';
        wait for 250 ns; -- Yeterince uzun süre kalıyor (12+ clock cycle)
        
        ----------------------------------------------------
        -- Senaryo 3: Basılıyken oluşan gürültü (Kısa Süreli Bırakma)
        ----------------------------------------------------
        sw <= '0';
        wait for 60 ns; -- Yine debounce süresinden kısa
        sw <= '1';
        wait for 200 ns;

        ----------------------------------------------------
        -- Senaryo 4: Başarılı Bırakma (Uzun Süreli)
        ----------------------------------------------------
        sw <= '0';
        wait for 250 ns;

        -- Simülasyonu bitir
        wait for 100 ns;
        assert false report "Simulasyon Tamamlandi" severity failure;
        wait;
    end process;

end behavior;
