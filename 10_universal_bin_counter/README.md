# 10. Hafta Evrensel İkili Sayıcı ve Simülasyonu.

Evrensel binary sayıcı kodu ve testbanch'i dizinde yer almaktadır, **xsim.sh** dosyasını çalıştırarak gerekli simülasyonu yapabiliriz

## xsim kullanımı
```sh
Usage: ./xsim.sh [--time <value>] [--view]

Options:
  --time <value>  Simulation duration (examples: 500ns, 1us, 2ms)
  --view          Open GTKWave after simulation
  -h, --help      Show this help

Examples:
  ./xsim.sh
  ./xsim.sh --time 2us
  ./xsim.sh --time 1500ns --view

```

bizim senaryomuzda vivado programındaki xsim'i simüle etmek için `sh xsim.sh --time 2000ns --view` kodu ile simülasyonumuzu yürütmemiz fazlasıyla yeterli olacaktır.

> [!NOTE]
> Programın çıktısı şu şekildedir:
> <img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/e1f795d4-5e28-48fb-a788-0bac6216b8ee" />


## Vivado

Vivado programında ise proje oluşturduktan sonra **bin_counter.vhd** ve **bin_counter_tb.vhd** dosyasını projeye dahil etmemizin ardından testbanch'i seçerek "*run simulation*" seçeneğine tıklamamız gerekmektedir, ve zaman simülasyonunu göreceğiz.

> [!WARNING]
> Temsili(**örnek**) görsel kullanılmıştır...
> <img width="1147" height="555" alt="image" src="https://github.com/user-attachments/assets/88177324-069a-40f5-afd7-2381b88813a3" />
