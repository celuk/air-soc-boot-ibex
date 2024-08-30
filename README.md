# air-soc
TEKNOFEST 2024 ÇİP TASARIMI MİKRODENETLEYİCİ KATEGORİSİ KASIRGA-HAVA

CV32E40P RISC-V Core IP based SoC

## Ortam Kurulumu

Bu repoda nix tabanlı bir ortam kullanılmaktadır ve simülasyon ve derleme için gerekli araçlar Modelsim, riscv-gnu-toolchain, cocotb vs. otomatik olarak build edilir, kurulur. 

nix'i linux tabanlı işletim sisteminizde yüklemek için aşağıdaki komutları çalıştırın: 

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

```bash
mkdir -p $HOME/.config/nix && touch $HOME/.config/nix/nix.conf && echo -e "\n# Added by script\nexperimental-features = nix-command flakes\nmax-jobs = auto\nuse-xdg-base-directories = true" | tee -a $HOME/.config/nix/nix.conf
```

Sistemi yeniden başlatın:

```bash
reboot
```

nix'in yüklenip yüklenmediğini kontrol edin:

```bash
nix-shell -p nix-info --run "nix-info -m"
```

Repoyu klonlayın ve submoduleleri de update edin:

```bash
git clone https://github.com/kasirgalabs/air-soc
```

```bash
cd air-soc
```

```bash
git submodule update --init --remote --recursive
```

nix environmentini aktive etmek için aşağıdaki komutu kullanın (`conda activate` gibi her yeni terminal açıldığında kullanılmalıdır): 

```bash
nix develop
```

İlk seferde toolları kuracak ve bu biraz uzun sürebilir fakat bir kere kurulduktan sonra, sonraki her yeni terminalde beklemeden çalışma ortamına ulaşabileceksiniz.

** Önemli Not: ** Kullanılan hostta eğer Modelsim lisansınız yoksa Modelsim'i kullanabilmek için önce lisans edinmeniz gerekmektedir:

https://www.intel.com/content/www/us/en/docs/programmable/683472/22-1/and-software-license.html

Lisans alırken host bilgisayarın mac adresinizi girmeniz gerekmektedir. (`ifconfig`)

Sonrasında, `.bashrc`'de ya da her terminali açtığınızda:

```bash
export LM_LICENSE_FILE=<your-questa-license-file-with-full-path>
```

## Ortam Kullanımı

Kurulumu yaptıktan sonra repo ana pathine giderek her yeni terminal açtığınızda:

```
cd air-soc

nix develop
```

Sonrasında örneğin `tests` dosyasındaki demo programını compile etmek için:

```bash
make compile <program_ismi>
```

```bash
make compile demo
```

Modelsim ile simülasyonunu yapmak için:

```bash
make sim <program_ismi>
```

```bash
make sim demo
```

Simülasyon `tb_air.py` cocotb kodunda bulunan `TIMEOUT` değerine kadar çalışacaktır, eğer daha erken bitirip bakmak isterseniz Ctrl+C tuş kombinasyonunu kullanın.

Sonrasında waveformu görüntülemek için aşağıdaki komutu çalıştırın:

```bash
make show
```

Coremark için compile komutu özeldir:

```bash
make coremark
```

```bash
make sim coremark
make show
```
