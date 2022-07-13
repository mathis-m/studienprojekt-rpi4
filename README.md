# studienprojekt-rpi4
Ignore the folders and yaml.

## Usage
First Argument is the GPIO PIN Number eg. GPIO 21 => arg=21

```bash
git clone https://github.com/mathis-m/studienprojekt-rpi4.git blink
cd blink/blinking-led
as -o blink blink.s
gcc -o blink blink.o
./blink 21
```