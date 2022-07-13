# studienprojekt-rpi4
Ignore the folders and yaml.

## Usage
First Argument is the GPIO PIN Number eg. GPIO 21 => arg=21

```bash
git clone https://github.com/mathis-m/studienprojekt-rpi4.git blink
cd blink/blinking-led
as -o blink.o blink.s
gcc -o blink blink.o
./blink 21
```

## Simple Version
Checkout the `simple_version` branch.
It is a somewhat simpler version it has the GPIO PIN 21(PIN) and corresponding values(GPFSEL2, GPCLR0, GPSET0, GPFSEL2_GPIO21_MASK, MAKE_GPIO21_OUTPUT) hardcoded.

```bash
git clone https://github.com/mathis-m/studienprojekt-rpi4.git blink
git checkout --track origin/simple_version
cd blink/blinking-led
as -o blink.o blink.s
gcc -o blink blink.o
./blink 21
```