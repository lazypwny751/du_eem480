# Düzce Üniversitesi EEM 480 - FPGA ile Sayısal Tasarıma Giriş.
Bu ders kapsamında VHDL üzerinden FPGA kullanımı ve mimari tasarımı yapılacak olup bu depoda da derse yönelik konu anlatımı ve kaynak kodları yer almaktadır.

> [!WARNING]
> Bu depodaki içerikler çıkmışlara yönelik ya da dersi geçmek amacıyla değil dersin mantığını anlamak ve anlatmak amacıyla hazırlanmıştır.

<img width="1024" height="1024" alt="starlight_reading_vhdl_book" src="https://github.com/user-attachments/assets/bea58b28-1e10-452f-8e95-026ca040922e" />

# Önceden kurulması gereken araçlar.
Bu ders içeriği projesinde kullanılan teknoloji yığını:
- sh: Otomasyonlar için POSIX uyumlu bir shell olmalıdır.
- LaTeX Compiler: Dokümanlar için LaTeX derleyicisi gereklidir.
- Make: Build almak için Make lazım.
- GHDL ve GTKWave: test ortamı için gerekli paketler:

> [!NOTE]
> llvm ya da gcc backend'ini C dili ile birlikte de kod ürettirebileceğimizi görmek için kuracağız, tamamen opsiyonel. 

```sh
apt install coreutils dash texlive-latex-base make ghdl gtkwave # opsiyonel olarak "ghdl-gcc" ya da "ghdl-llvm" kurulabilir.
```

# Yapı
## [**00_ders_harici**](00_ders_harici/)
Ders dışı dokümanlar ve kaynak kodları ve basit pratikler öntanımlar.

## [**01_giris**](01_giris/)
İlk haftaki konular ve kaynak kodları:
- FPGA kimdir? FPGA ile neler yapılır?
- Neden VHDL?
- FPGA için boardlar(mesela booleancard)

## Katkıda Bulunma

Katkılar her zaman memnuniyetle karşılanır.  
Büyük değişiklikler için lütfen önce bir konu (issue) açarak neyi değiştirmek istediğinizi anlatın.

Lütfen gerekli testleri güncellediğinizden emin olun.

Teşekkürler ❤️

# Lisans
[MIT](https://opensource.org/license/mit)
