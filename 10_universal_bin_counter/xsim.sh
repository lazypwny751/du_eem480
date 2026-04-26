#!/bin/sh

# GHDL simulasyonunu calistiran, istege bagli GTKWave acan basit POSIX betigi.
# Eski ciktilari temizler, analyze/elaborate/simulate adimlarini kosar, VCD uretir.
set -eu

TOP_TB="bin_counter_tb"
WAVE="${TOP_TB}.vcd"
SIM_TIME="1us"
OPEN_WAVE=0

usage() {
  cat <<'EOF'
Usage: ./xsim.sh [--time <value>] [--view]

Options:
  --time <value>  Simulation duration (examples: 500ns, 1us, 2ms)
  --view          Open GTKWave after simulation
  -h, --help      Show this help

Examples:
  ./xsim.sh
  ./xsim.sh --time 2us
  ./xsim.sh --time 1500ns --view
EOF
}

# Komut satiri seceneklerini ayikla.
# Bilinmeyen secenekler sessiz hatayi onlemek icin reddedilir.
while [ "$#" -gt 0 ]; do
  case "$1" in
    --time)
      if [ "$#" -lt 2 ]; then
        echo "Error: --time requires a value"
        usage
        exit 1
      fi
      SIM_TIME="$2"
      shift 2
      ;;
    --view)
      OPEN_WAVE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

# Onceki derleme veritabani ve dalga dosyasini sil (her calismada temiz baslangic).
rm -f *.cf "${WAVE}"

# Adim 1: kaynak dosyalari analyze et (soz dizimi + work kutuphanesine derleme).
echo "[1/3] Analyze VHDL sources"
ghdl -a --std=08 bin_counter.vhd bin_counter_tb.vhd

# Adim 2: testbench'i elaborate et (calisabilir simulasyon modeli olustur).
echo "[2/3] Elaborate testbench"
ghdl -e --std=08 "${TOP_TB}"

# Adim 3: simulasyonu calistir ve dalga dosyasini yaz.
echo "[3/3] Run simulation for ${SIM_TIME} and dump VCD"
# GHDL'nin --stop-time secenegiyle sabit sure calistir.
set +e
ghdl -r --std=08 "${TOP_TB}" --stop-time="${SIM_TIME}" --vcd="${WAVE}"
rc=$?
set -e

if [ ! -f "${WAVE}" ]; then
  # VCD yoksa simulasyon beklenen sekilde tamamlanmamis demektir.
  echo "Simulation did not produce ${WAVE}"
  exit 1
fi

if [ "$rc" -ne 0 ]; then
  # Yaygin durum: testbench kendini assert ile sonlandirir.
  echo "Note: testbench finished with assertion before stop-time (or another runtime error occurred)."
fi

echo "Waveform ready: ${WAVE}"

if [ "${OPEN_WAVE}" -eq 1 ]; then
  # --view seciliyse shell yerine GTKWave sureci calisir.
  exec gtkwave "${WAVE}"
fi

echo "Use: ./xsim.sh --time 2us --view"
