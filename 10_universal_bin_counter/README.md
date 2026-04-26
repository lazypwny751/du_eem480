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

## Vivado

Vivado programında ise proje oluşturduktan sonra **bin_counter.vhd** ve **bin_counter_tb.vhd** dosyasını projeye dahil etmemizin ardından testbanch'i seçerek "*run simulation*" seçeneğine tıklamamız gerekmektedir, ve zaman simülasyonunu göreceğiz.
