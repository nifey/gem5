# TODO
See if gem5.fast works prints dprintf messages
see if x86kvmcpu can be used
check if newer kernel version can be used - da zhang
see if command option can be used to run the benchmarks

# Building Gem5

1. Clone the gem5 repository
git clone https://github.com/gem5/gem5

2. Install dependencies
sudo apt-get install scons 

3. Build gem5
cd gem5
scons build/X86/gem5.opt -j9

4. Test if gem5 works by running a hello world program in syscall emulation mode
./build/X86/gem5.opt --debug-flags=MMU --debug-file=mmu_trace.log ./configs/example/se.py --cpu-type=TimingSimpleCPU --caches --l2cache -c tests/test-progs/hello/bin/x86/linux/hello

# To run in full system mode
Ref: https://icomparch.blogspot.com/2014/10/gem5-instructions-for-enabling-full.html

1. Download full system files from http://www.m5sim.org/Download
mkdir fsfiles
cd fsfiles
# get x86 full system files
wget http://www.m5sim.org/dist/current/x86/x86-system.tar.bz2
tar -xvf x86-system.tar.bz2
# get x86 config files
wget http://www.m5sim.org/dist/current/x86/config-x86.tar.bz2
tar -xvf config-x86.tar.bz2

2. Set M5_PATH variable as the directory that contains the disk and binaries folder
vi ~/.bashrc
export M5_PATH=path/to/the/folder/fsfiles
source ~/.bashrc

3. Rename linux-x86.img to x86root.img in the disks folder

4. It also needs an image called linux-bigswap2.img. It is only present in the Alpha full system files so download Alpha full system files 
wget http://m5sim.org/dist/current/m5_system_2.0b3.tar.bz2
tar -xvf m5_system_2.0b3.tar.bz2
mv m5_system_2.0b3/disks/linux-bigswap2.img fsfiles/disks

5. Run the full system simulation

./build/X86/gem5.opt ./configs/example/fs.py --cpu-type=TimingSimpleCPU --caches --l2cache --kernel=/home/e0-243-2/fsfiles/binaries/x86_64-vmlinux-2.6.22.9

Open another terminal and type
cd util/term
make
./m5term 3456

After sometime it will load a bash shell

To list all options that can be used with fs.py script, run:
./build/X86/gem5.opt configs/example/fs.py -h

# Memory tracing with Gem5

As a part of our term project we wanted to get a trace of DRAM accesses for running SPEC and PARSEC programs and find patterns in the access trace. We also wanted to differentiate DRAM accesses that are due to Page table walks and other DRAM accesses.

Gem5 source code has DPRINTF statements in all the source files. They are not actually printed or saved unless we pass a debug flag while running the simulations.

./build/X86/gem5.opt --debug-flags=DRAM --debug-file=trace.log ./configs/example/fs.py --cpu-type=TimingSimpleCPU --caches --l2cache --kernel=/home/e0-243-2/fsfiles/binaries/x86_64-vmlinux-2.6.22.9

The trace file could get big very quick. We can tell gem5 to save the log in compressed format by appending .gz to the trace file like
./build/X86/gem5.opt --debug-flags=DRAM --debug-file=trace.log.gz ./configs/example/fs.py --cpu-type=TimingSimpleCPU --caches --l2cache --kernel=/home/e0-243-2/fsfiles/binaries/x86_64-vmlinux-2.6.22.9

# Checkpointing in Gem5
After gem5 has booted, type
m5 checkpoint

This will create a ckpt.<some_number> file in the m5out directory.

To run from the checkpoint use --checkpoint-restore=N and --restore-with-cpu=<Type of cpu used to record the checkpoint>. This will only start recording DPRINTF messages after the checkpoint.
./build/X86/gem5.opt --debug-flags=DRAM --debug-file=trace.log.gz ./configs/example/fs.py --cpu-type=TimingSimpleCPU --caches --l2cache --kernel=/home/e0-243-2/fsfiles/parsec/x86_64-vmlinux-2.6.28.4-smp --checkpoint-restore=1 --restore-with-cpu=TimingSimpleCPU

# Running PARSEC benchmarks on Gem5

For this I am going to use the images files provided by UC Texas

1. Download the image and kernel
wget http://www.cs.utexas.edu/~parsec_m5/x86_64-vmlinux-2.6.28.4-smp
wget http://www.cs.utexas.edu/~parsec_m5/x86root-parsec.img.bz2

bzip2 -d x86root-parsec.img.bz2
mv x86root-parsec.img x86root.img

wget http://www.cs.utexas.edu/~parsec_m5/inputsets.txt
wget http://www.cs.utexas.edu/~parsec_m5/writescripts.pl
wget http://www.cs.utexas.edu/~parsec_m5/hack_back_ckpt.rcS

2. Generate gem5 rc script using writescripts.pl

chmod +x writescripts.pl
./writescripts.pl <benchmark_name> <number of threads>

3. This will generate multiple scripts for different datasets. To run the scripts in gem5 add --script=<script_file> to the gem5.opt command like:

./build/X86/gem5.opt --debug-flags=DRAM --debug-file=trace.log.gz ./configs/example/fs.py --cpu-type=TimingSimpleCPU --caches --l2cache --kernel=/home/e0-243-2/fsfiles/parsec/x86_64-vmlinux-2.6.28.4-smp --checkpoint-restore=1 --restore-with-cpu=TimingSimpleCPU --script=/home/e0-243-2/fsfiles/parsec/rcscripts/facesim_3c_simlarge.rcS

# Adding SPEC benchmarks to image (Working with image files)
I'm using the SPEC2000 Integer benchmarks. Because it is old, I am not able to compile it with GCC on my computer.

1. Download the PARSEC image from UCTexas

2. Mount the image

mkdir mnt
sudo mount -o loop,offset=32256 x86root-parsec.img mnt

3. Copy SPEC files into the image
mkdir mnt/spec
cp -r CINT2000 mnt/spec

3. Chroot
sudo mount --bind /proc/ mnt/proc/
sudo mount --bind /dev/ mnt/dev/
sudo chroot mnt

4. Compile SPEC CINT2000
cd spec/CINT2000/tools/src
bash buildtools

5. Exit Chroot and unmount
sudo umount mnt/proc
sudo umount mnt/dev
sudo umount mnt

