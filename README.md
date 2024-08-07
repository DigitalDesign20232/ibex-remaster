<p align="center">
  <a href="https://github.com/DigitalDesign20232/ibex-remaster">
    <img src="https://scontent.fhan5-10.fna.fbcdn.net/v/t39.30808-6/288878449_1691636501198841_6225749296084830059_n.jpg?_nc_cat=111&ccb=1-7&_nc_sid=6ee11a&_nc_eui2=AeG3KUYQEnvvIPpRXO3rhkAGfhOjnF2NLHN-E6OcXY0scz6wB5J1YiHh1oUwj6ea79Gs7l9ihxXllPbdYINT-v69&_nc_ohc=XuxPpH3h6tkQ7kNvgFCtf9e&_nc_ht=scontent.fhan5-10.fna&gid=AvJv1RWhFrOK_jQzxntt6zX&oh=00_AYDIYc4MbgMYYoGQNtY9Wm56G1cCKBszjl968EAhsm5cPw&oe=66AFF19D" alt="TachmonKS 2023.2" width=72 height=72>
  </a>

  <h3 align="center">TachmonKS 2023.2 Team</h3>

  <p align="center">
    Le Thanh Luan - Tran Quang Huy - Pham Truong Ha Phuong - Le Trung Quan
    <br>
    <a href="https://github.com/DigitalDesign20232/ibex-remaster/issues/new?template=bug.md">Report bug</a>
    ·
    <a href="https://github.com/DigitalDesign20232/ibex-remaster/issues/new?template=feature.md&labels=feature">Request feature</a>
  </p>
</p>

# Ibex Remaster

A remastered version of Ibex processor with some customizations.

## Table of Contents

- [Description](#description)
- [Quick Start](#quick-start)
- [Ibex Demo System](ibex-demo-system/README.md)

## Description

This project serves as the final exam for our Digital Design Course, organized by EDABK Lab.

Our goal is to reimplement and enhance the original Ibex core - a vital component of the lowRISC ecosystem. Through meticulous design and optimization, we aim to create a refined processor core with our own features.

## Quick Start

Clone the repository with `git`

```bash
  # For example: Ubuntu - Clone using SSH
  git clone git@github.com:DigitalDesign20232/ibex-remaster.git
  cd ibex-remaster/ibex-demo-system
  # If SSH does not work, try using HTTPS
  # git clone https://github.com/DigitalDesign20232/ibex-remaster.git
  # cd ibex-remaster/ibex-demo-system

  # For example: Windows - Clone using HTTPS
  # git clone https://github.com/DigitalDesign20232/ibex-remaster.git
  # cd ibex-remaster/ibex-demo-system
```
## Building Software

### C stack

First the software must be built.
This can be loaded into an FPGA to run on a synthesized Ibex processor, or passed
to a verilator simulation model to be simulated on a PC.

```
mkdir sw/c/build
pushd sw/c/build
cmake ..
make
popd
```

Note the FPGA build relies on a fixed path to the initial binary (blank.vmem) so
if you want to create your build directory elsewhere you need to adjust the path
in `ibex_demo_system.core`

## Building Simulation

The Demo System simulator binary can be built via FuseSoC. From the directory `ibex-demo-system/` run:

```sh
fusesoc --cores-root=. run --target=sim --tool=verilator --setup --build lowrisc:ibex:demo_system
```

## Running the Simulator

Having built the simulator and software, to simulate using Verilator we can use the following commands.
`<sw_elf_file>` should be a path to an ELF file  (or alternatively a vmem file)
built as described above. Use `./sw/c/build/demo/hello_world/demo` to run the `demo`
binary.

Run from the `ibex-demo-system/` run:
```sh
# For example :
./build/lowrisc_ibex_demo_system_0/sim-verilator/Vtop_verilator \
  --meminit=ram,./sw/c/build/demo/hello_world/demo

# You need to substitute the <sw_elf_file> for a binary we have build above.
./build/lowrisc_ibex_demo_system_0/sim-verilator/Vtop_verilator [-t] --meminit=ram,<sw_elf_file>
```

Pass `-t` to get an FST trace of execution that can be viewed with
[GTKWave](http://gtkwave.sourceforge.net/).

```
Simulation statistics
=====================
Executed cycles:  5899491
Wallclock time:   1.934 s
Simulation speed: 3.05041e+06 cycles/s (3050.41 kHz)

Performance Counters
====================
Cycles:                     457
NONE:                       0
Instructions Retired:       296
LSU Busy:                   108
Fetch Wait:                 20
Loads:                      53
Stores:                     55
Jumps:                      21
Conditional Branches:       12
Taken Conditional Branches: 7
Compressed Instructions:    164
Multiply Wait:              0
Divide Wait:                0
```

## Building FPGA bitstream

FuseSoC handles the FPGA build. Vivado tools must be setup beforehand. From the
`ibex-demo-system/`:

```
fusesoc --cores-root=. run --target=synth_zcu104 --setup --build lowrisc:ibex:demo_system
```

The prefered board is ZCU104, but you can also use different synthesis targets.
For example, to use the Sonata board change the target to `synth_sonata`.

## Programming FPGA

To program the FPGA, execute the programming operation manually with vivado:

```
make -C ./build/lowrisc_ibex_demo_system_0/synth-_zcu104-vivado/ pgm
```

## Loading an application to the programmed FPGA

The `util/load_demo_system.sh` script can be used to load and run an application.
You can choose to immediately run it or begin halted, allowing you to attach a debugger.

```bash
# Run demo
./util/load_demo_system.sh run ./sw/c/build/demo/hello_world/demo ./util/zcu104-olimex-openocd-cfg.tcl

./util/load_demo_system.sh run ./sw/c/build/demo/lcd_st7735/lcd_st7735 ./util/zcu104-olimex-openocd-cfg.tcl

# Load demo and start halted awaiting a debugger
./util/load_demo_system.sh halt ./sw/c/build/demo/hello_world/demo ./util/zcu104-olimex-openocd-cfg.tcl
```

To view terminal output use screen:

```bash
# Look in /dev to see available ttyUSB devices
screen /dev/ttyUSB1 115200
```

If you see an immediate `[screen is terminating]`, it may mean that you need super user rights.
In this case, you may try using `sudo`.

To exit from the `screen` command, you should press `ctrl-a` followed by `k`.
You will need to confirm the exit by pressing `y`.

## Debugging an application

Either load an application and halt (see above) or start a new OpenOCD instance:

```
openocd -f util/zcu104-olimex-openocd-cfg.tcl
```

Then run GDB against the running binary and connect to `localhost:3333` as a remote target:

```bash
riscv32-unknown-elf-gdb ./sw/c/build/demo/hello_world/demo

(gdb) target extended-remote localhost:3333
```