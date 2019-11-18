#!/bin/bash
./build/X86/gem5.opt --debug-flags=DRAM --debug-file=trace.log.gz ./configs/example/fs.py --cpu-type=TimingSimpleCPU --caches --l2cache --kernel=/home/e0-243-2/fsfiles/binaries/x86_64-vmlinux-2.6.22.9
