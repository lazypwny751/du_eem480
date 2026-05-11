#!/bin/sh

# GHDL simulasyonunu calistiran, istege bagli GTKWave acan basit POSIX betigi.
# Eski ciktilari temizler, analyze/elaborate/simulate adimlarini kosar, VCD uretir.
set -eu

TOP_TB="db_rt_tb"
WAVE="${TOP_TB}.vcd"
SIM_TIME="2us"
OPEN_WAVE=0

usage() {
  cat <<'HELP'
Usage: ./xsim.sh [--time <value>] [--view]

Options:
  --time <value>  Simulation duration (examples: 500ns, 1us, 2ms)
  --view          Open GTKWave after simulation
  -h, --help      Show this help

Examples:
  ./xsim.sh
  ./xsim.sh --time 2us
  ./xsim.sh --time 1500ns --view
HELP
}

# Komut satiri seceneklerini ayikla.
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

# Adim 1: kaynak dosyalari analyze et 
echo "[1/3] Analyze VHDL sources"
ghdl -a --std=08 db_rt.vhdl db_rt_tb.vhdl

# Adim 2: testbench'i elaborate et
echo "[2/3] Elaborate testbench"
ghdl -e --std=08 "${TOP_TB}"

# Adim 3: simulasyonu calistir ve dalga dosyasini yaz.
echo "[3/3] Run simulation for ${SIM_TIME} and dump VCD"
set +e
ghdl -r --std=08 "${TOP_TB}" --stop-time="${SIM_TIME}" --vcd="${WAVE}"
rc=$?
set -e

if [ ! -f "${WAVE}" ]; then
  echo "Simulation did not produce ${WAVE}"
  exit 1
fi

if [ "$rc" -ne 0 ]; then
  echo "Note: testbench finished with assertion before stop-time (or another runtime error occurred)."
fi

echo "Waveform ready: ${WAVE}"

if [ "${OPEN_WAVE}" -eq 1 ]; then
  exec gtkwave "${WAVE}"
fi

echo "Use: ./xsim.sh --time 200ms --view"
