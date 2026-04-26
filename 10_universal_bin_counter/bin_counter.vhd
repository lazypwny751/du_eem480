library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Evrensel ikilik sayac.
-- Bit genisligi generic N ile ayarlanabilir.
entity univ_bin_counter is
	generic (
		-- Sayac genisligi (bit cinsinden). Varsayilan: 8 bit.
		N : integer := 8
	);
	port (
		-- Saat ve asenkron reset.
		clk, reset         : in  std_logic;
		-- Kontrol girisleri:
		-- syn_clr: senkron temizleme, load: paralel yukleme,
		-- en: saymayi etkinlestirme, up: yon (1=yukari, 0=asagi).
		syn_clr, load, en,
		up                 : in  std_logic;
		-- Paralel yukleme veri girisi.
		d                  : in  std_logic_vector(N - 1 downto 0);
		-- Uc bayraklari: sayac max/min degerdeyken 1 olur.
		max_tick, min_tick : out std_logic;
		-- Anlik sayac degeri.
		q                  : out std_logic_vector(N - 1 downto 0)
	);
end univ_bin_counter;

architecture arch of univ_bin_counter is
	-- Mevcut durum yazmaci.
	signal r_reg  : unsigned(N - 1 downto 0);
	-- Kombinasyonel sonraki-durum degeri.
	signal r_next : unsigned(N - 1 downto 0);
begin
	-- Durum yazmaci:
	-- Asenkron reset sayaci aninda sifirlar.
	-- Her yukselen kenarda yazmaca r_next yuklenir.
	process (clk, reset)
	begin
		if (reset = '1') then
			r_reg <= (others => '0');
		elsif (clk'event and clk = '1') then
			r_reg <= r_next;
		end if;
	end process;

	-- Sonraki-durum onceligi (yukaridan asagiya):
	-- 1) syn_clr ile sifirla
	-- 2) load ile d degerini yukle
	-- 3) en + up iken yukari say
	-- 4) en + not up iken asagi say
	-- 5) aksi durumda mevcut degeri koru
	r_next <= (others => '0') when syn_clr = '1' else
						unsigned(d)      when load = '1' else
						r_reg + 1        when en = '1' and up = '1' else
						r_reg - 1        when en = '1' and up = '0' else
						r_reg;

	-- Cikislar:
	-- q, mevcut yazmac degerini yansitir.
	-- max_tick ve min_tick uc degerlerde 1 olur.
	q        <= std_logic_vector(r_reg);
	-- N bit isaretsiz sayacta maksimum deger 2^N - 1'dir.
	max_tick <= '1' when r_reg = (2 ** N - 1) else '0';
	min_tick <= '1' when r_reg = 0 else '0';
end arch;
