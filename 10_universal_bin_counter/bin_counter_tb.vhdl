library ieee;
use ieee.std_logic_1164.all;

-- Evrensel ikilik sayac icin testbench.
-- Ust seviye simulasyon sarmalayicisi oldugu icin porta ihtiyac yoktur.
entity bin_counter_tb is
end bin_counter_tb;

architecture arch of bin_counter_tb is
	-- Bu testbench'te kullanilan sayac genisligi.
	constant THREE : integer := 3;
	constant T     : time    := 20 ns; -- bir tam saat periyodu

	-- DUT giris kontrol ve saat/reset sinyalleri.
	signal clk, reset         : std_logic;
	signal syn_clr, load, en,
	up                        : std_logic;
	-- DUT veri girisi ve izlenen cikislar.
	signal d                  : std_logic_vector(THREE - 1 downto 0);
	signal max_tick, min_tick : std_logic;
	signal q                  : std_logic_vector(THREE - 1 downto 0);
begin
	-- DUT ornegi (3 bit evrensel ikilik sayac)
	counter_unit : entity work.univ_bin_counter(arch)
		generic map (
			N => THREE
		)
		port map (
			clk      => clk,
			reset    => reset,
			syn_clr  => syn_clr,
			load     => load,
			en       => en,
			up       => up,
			d        => d,
			max_tick => max_tick,
			min_tick => min_tick,
			q        => q
		);

	-- Surekli calisan saat ureticisi.
	-- 20 ns periyot uretir: T/2 sure 0, T/2 sure 1.
	-- Bu surec simulasyon boyunca durmaz.
	process
	begin
		clk <= '0';
		wait for T / 2;
		clk <= '1';
		wait for T / 2;
	end process;

	-- Baslangic reset darbesi.
	-- Reset ilk yarim cevrimde 1, sonra serbest birakilir.
	reset <= '1', '0' after T / 2;

	-- Ana uyaran sirasi.
	-- Sayaci dogrulamak icin load/clear/enable/up-down kontrollerini uygular.
	-- Kontrol degisimleri, yukselen kenar guncellemesine temiz denk gelsin diye
	-- dusen kenarda bekleme kullanilir.
	process
	begin
		-- Aktif testler baslamadan once ilk kontrol degerleri.
		syn_clr <= '0';
		load    <= '0';
		up      <= '1'; -- yukari say
		d       <= (others => '0');
		wait until falling_edge(clk);
		wait until falling_edge(clk);

		-- Load testi: sayaca ikilik 3 ("011") yukle.
		load <= '1';
		en   <= '0';
		d    <= "011";
		wait until falling_edge(clk);
		load <= '0';

		-- enable=0 iken 2 saat bekle; deger korunmali.
		wait until falling_edge(clk);
		wait until falling_edge(clk);

		-- Senkron clear testi: bir sonraki aktif kenarda sifirlama.
		syn_clr <= '1'; -- sifirla
		wait until falling_edge(clk);
		syn_clr <= '0';

		-- Yukari sayma testi, sonra duraklat ve devam et.
		en <= '1'; -- say
		up <= '1';
		for i in 1 to 10 loop -- 10 saat cevrimi ilerle
			wait until falling_edge(clk);
		end loop;
		en <= '0';
		wait until falling_edge(clk);
		wait until falling_edge(clk);
		en <= '1';
		wait until falling_edge(clk);
		wait until falling_edge(clk);

		-- Asagi sayma testi.
		up <= '0';
		for i in 1 to 10 loop -- 10 saat cevrimi ilerle
			wait until falling_edge(clk);
		end loop;

		-- wait-until kosulu testi: q=2 oldugunda devam et.
		wait until q = "010";
		wait until falling_edge(clk);
		up <= '1';

		-- Olay bekleme testi: min_tick degistiginde devam et.
		wait on min_tick;
		wait until falling_edge(clk);
		up <= '0';
		wait for 4 * T; -- 80 ns bekle
		en <= '0';
		wait for 4 * T;

		-- Simulasyonu bilerek sonlandir.
		-- Cogu simulator bunu simulasyonu durdurmak icin kontrollu failure olarak gosterir.
		assert false
			report "Simulation Completed"
			severity failure;
	end process;
end arch;
