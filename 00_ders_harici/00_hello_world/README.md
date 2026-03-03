Gerekli paketler kurulu ise şu an buludnuğumuz dizinde **run.sh** dosyamızı çalıştırıp çıktımızı görelim.

```sh
sh run.sh
```

Çıktı aşağıda belirtilen gibi olmalıdır:

```
Analyzing...
Elaborating...
Running simulation...
tb/hello_world_tb.vhd:11:9:@0ms:(report note): Hello World!
```

bu sadece test çıktısı almak için basit bir **vhdl** kodu, herhangi bir karşılığı yok.
Bu yüzden gtkwave kodunu simüle etmedik lakin ürettirdik, eğer çalıştıracak olsaydık, **gtkwave** bize
dosya içerisinde herhangi bir sembol bulamadığını söyleyecekti, ama az buçuk yapı nasıl bunu anlamak için
ghdl'den içeriği boş **vcd** dosyasını da üretmesini istedik.
Yani bir sinyal karşılığı yok, yani sadece
"*bak artık vhdl yazıyorum.*" demek için yaptığımız bir çalışma. 
