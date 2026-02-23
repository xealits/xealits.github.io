---
layout: post
slug: buspirate_3.6_notes
title: Notes on Bus Pirate 3.6 and I2C
tags: electronics gadgets
---

<summary>
"The Bus Pirate is an open source hacker multi-tool that talks to electronic stuff."
An excellent tool. The post writes up some basics on how Bus Pirate 3.6 works,
and how to talk on an I2C bus with it.
For example,
how to read the ID register 0xD0 of the barometric sensor BMP280 from Bosch.
</summary>

[Bus Pirate][ian_site] is a gadget that talks serial protocols, such as I2C, SPI, etc.
You can execute arbitrary transactions or sniff the traffic on the bus.
There are legacy versions [like 3][seeed_3p6] and 4,
which firmware is supported by [the community][community_legacy_buspirate].
The newer versions 5 and 6 have [a wider support][new_buspirate].

Plenty of resources and tutorials about Bus Pirate are available on the web:
from [Sparkfun][sparkfun_tutorial],
on [Dangerous Prototypes](http://dangerousprototypes.com/docs/Bus_Pirate#Tutorials) site,
one [the website for the new versions](https://docs.buspirate.com/docs/tutorial-basics/quick-setup/), etc.
In this post, I just want to write up a typical sequence of actions for
when you hook it up and use it to send a couple I2C commands:

* Just connect the Bus Pirate v3.6 to USB and talk with it using `screen` on Linux.
* Send some I2C commands at 3.3V level, and without any I2C device connected,
i.e. when a scan of the bus addresses finds no devices.
* Connect a board with the BMP280 sensor chip and read its ID register.

My BusPirate is version v3.6 (the firmware is v5.10 (r559)).
Here is its photo:

<img class="Figure" alt="Bus Pirate v3.6" src="/dir/2026-02-buspirate/buspirate-3p6-image.jpeg"/>


# Talking with Bus Pirate over `screen`

When you plug a USB cable:
* The red PWR LED on the BusPirate goes on and stays on.
* Other (green) LEDs quickly blink and go off. The "USB" LED also blinks, goes off and stays off.
The blinikng shows the activity on the serial connection to Linux.
* Linux also prints to `dmesg` that it found a new USB device, FTDI FT232R USB UART,
and says "[the device] is now attached on ttyUSB0".
Indeed, the `/dev/ttyUSB0` is there.

At this point, Bus Pirate should be available to talk on the serial console.
Let's use `screen` for the serial connection.
Launch it with root permissions:

```
$ sudo screen /dev/ttyUSB0 115200
```

It shows a blank screen, no prompt.
If there was a prompt line from the device, it was pushed to the serial port
before the `screen` launched, so there is nothing logged.
But the commands work. The `?` help command shows everything:

```
?
General                                 Protocol interaction
---------------------------------------------------------------------------
?       This help                       (0)     List current macros
=X/|X   Converts X/reverse X            (x)     Macro x
~       Selftest                        [       Start 
#       Reset                           ]       Stop
$       Jump to bootloader              {       Start with read
&/%     Delay 1 us/ms                   }       Stop
a/A/@   AUXPIN (low/HI/READ)            "abc"   Send string
b       Set baudrate                    123
c/C     AUX assignment (aux/CS)         0x123   
d/D     Measure ADC (once/CONT.)        0b110   Send value
f       Measure frequency               r       Read 
g/S     Generate PWM/Servo              /       CLK hi
h       Commandhistory                  \       CLK lo
i       Versioninfo/statusinfo          ^       CLK tick
l/L     Bitorder (msb/LSB)              -       DAT hi
m       Change mode                     _       DAT lo
o       Set output type                 .       DAT read
p/P     Pullup resistors (off/ON)       !       Bit read
s       Script engine                   :       Repeat e.g. r:10
v       Show volts/states               .       Bits to read/write e.g. 0x55.2
w/W     PSU (off/ON)            <x>/<x= >/<0>   Usermacro x/assign x/list all
HiZ>    
```

And the `i` command shows the board information:
``` 
HiZ>i
Bus Pirate v3b
Firmware v5.10 (r559)  Bootloader v4.4
DEVID:0x0447 REVID:0x3046 (24FJ64GA002 B8)
http://dangerousprototypes.com
HiZ>
```

Here, `HiZ>` is the current "high impedance" mode with no bus communication,
which is default on startup.

Notice, if you forget `sudo`, screen will abort like this:
```
$ screen /dev/ttyUSB0 115200
[screen is terminating]
```

If you see the `?` and `i` commands work, the firmware should be OK for action.
However, it may be needed to flash a newer firmware:
[the community fork for the Bus Pirate versions 3 and 4][community_legacy_buspirate],
or [the firmware of the new versions 5 and 6](https://docs.buspirate.com/docs/tutorial-basics/firmware-update/).
I did not try to flash a newer firmware on Linux yet,
because my current firmware v5.10 (r559) seems to work fine.


# Power up the Bus Pirate IO and select 3.3V for the I2C communication

Just to note, to start operating the bus interface, you need to select a bus mode.
The power supply command is `W`. But:
```
HiZ>W
Command not used in this mode
HiZ>
```

Let's select I2C, as in the [Sparkfun tutorial][sparkfun_tutorial]:
```
HiZ>m
1. HiZ
2. 1-WIRE
3. UART
4. I2C
5. SPI
6. 2WIRE
7. 3WIRE
8. LCD
9. DIO
x. exit(without change)

(1)>4
Set speed:
 1. ~5KHz
 2. ~50KHz
 3. ~100KHz
 4. ~400KHz
 
(1)>4
Ready
I2C>
```

Now the green MODE LED is ON.

PSU ON now:
```
I2C>W
Power supplies ON
I2C>
```

Now the red VREG LED is ON.
And indeed, a multimeter shows that 5V and 3.3V pins are on.
All good.

The tutorial goes on to the pull-up resistors:
> At this point you might also want to enable pull-up resistors.
> **To do so you need to connect the VPU pin to the correct voltage supply.**
> Then 'P' will connect the resistors.
> The LSM303C Breakout already has pull-up resistors, so we can skip this step.
> We are ready to start communicating with the IC.

But, in my case, nothing is connected to the bus yet.
So, if the VPU pin is not connected and the bus lines are not pulled up,
Bus Pirate will notice and warn about it (very nice):
```
I2C>P
Pull-up resistors ON
Warning: no voltage on Vpullup pin
I2C>
```

Let's connect the VPU and the 3.3V pins of the Bus Pirate IO,
which will set the 3.3V level for the communication, i.e. CLK and SDA lines.
```
I2C>P
Pull-up resistors ON
I2C>
```

* Now `P` does not complain.
* The CLK and SDA lines jump to 3.3V. It is ready for I2C communication.

The wiring gets a bit cumbersome:
you have to use a breadboard to connect
the 3.3V power for the target I2C device
and also the VPU pin.
And it seems like my BMP280 boards
[from Pimoroni](https://shop.pimoroni.com/products/bme280-breakout?variant=29420960677971)
(very nice 2-6V input)
and [Az-Delivery](https://www.az-delivery.de/fr/products/azdelivery-bmp280-barometrischer-sensor-luftdruck-modul-fur-arduino-und-raspberry-pi)
(which requires 3.3V,
but their wiring diagram on Amazon suggested to connect the power to the 5V pin on Arduino Uno,
which burnt two of their handy little boards for me)
do not have the pull-up resistors.
So, I have to keep the VPU connected to the 3.3 volts.


# I2C signals on a scope without any connected device

Let's just output some I2C frames and look at the signals on the CLK and SDA lines with a scope.

Bus Pirate provides "macro" i.e. sequences of transactions.
The firmware already comes with a couple of them.
List available macro:
```
I2C>(0)
 0.Macro menu
 1.7bit address search
 2.I2C sniffer
I2C>
```

Excellent macros.

The address scan finds nothing, because nothing is connected yet:
```
I2C>(1)
Searching I2C address space. Found devices at:


I2C>
```

A scope capture looks like this, with purple CLK and yellow SDA:

<img class="Figure"
alt="Scope capture of I2C frames in an address scan"
src="/dir/2026-02-buspirate/i2c-frames-image.jpeg"/>

You can see that the clock signal rises up so slowly that the signal does not look square.
An I2C device pulls down the line, but the pull up is done by just a resistor.
It makes the bus simpler in hardware, but limits its speed.
That is the main reason [why SPI bus is faster than I2C](https://forum.microchip.com/s/topic/a5C3l000000MfHLEA0/t388038):

> In SPI, devices use push-pull drivers to drive all lines both high and low, which minimizes the time to change the states of the line.  The SPI protocol has no maximum speed and speeds in excess of 100 MHz have been achieved.
>
> In I2C, all lines are open-collectors where the device only drives the line low.  When the device releases the line, a pull-up resistor pulls the line high.  Due to capacitance of the line, it goes to high relatively slow.  Because of this, the clock rate must be reduced to allow time for the line to pull high.  The I2C protocol has 100 kHz standard speed, 400 kHz fast mode, 1 MHz fast mode plus, 3.4 MHz high speed mode, and 5 MHz ultra-fast mode.


## Send a single full I2C transaction

Bus Pirate firmare has this scripting [language of the bus commands](https://docs.buspirate.com/docs/command-reference/#bus-commands),
where the bus start condition is `[`, the end condition is `]`,
and you can send any bytes in the middle.
A single transaction `[ 12 ]` looks like this on the scope:

<img class="Figure"
alt="A single I2C bus transaction"
src="/dir/2026-02-buspirate/i2c-transaction-image.jpeg"
/>

In I2C, when a device controls the bus to send the transaction,
it pulls the CLK line down as the bus Start Condition (S),
clocks in the data bits on SDA, and releases the bus as the Stop Condition (P).


# Talk to a BMP280 barometric sensor

[BMP280][bmp280_datasheet] is a barometric pressure sensor from Bosch.
It can talk SPI or I2C, with an address 0x76 or 0x77.
These options are selected by pulling its pins.

I have
[a Pimoroni](https://shop.pimoroni.com/products/bme280-breakout?variant=29420960677971)
(2-6V input)
and [an Az-Delivery](https://www.az-delivery.de/fr/products/azdelivery-bmp280-barometrischer-sensor-luftdruck-modul-fur-arduino-und-raspberry-pi)
(3.3V only, 5V fries it)
boards with this sensor.

It is straightforward how to connect Bus Pirate to these boards for I2C communication:
the power pins are GND and 3.3V, the data bus pins are CLK clock and MOSI as the SDA (Serial Data) of the bus.
That is a nice feature of I2C. The bus is just 4 wires with straightforward roles.

After connecting a board, the BMP280 chip shows up in the Bus Pirate I2C address scan like this:

```
I2C>(0)
 0.Macro menu
 1.7bit address search
 2.I2C sniffer
I2C>
I2C>(1)
Searching I2C address space. Found devices at:
0xEC(0x76 W) 0xED(0x76 R)

I2C>
```

The command to read the 0xD0 ID register from BMP280 (probably the seconds `r` was redundant):
```
I2C>[ 0xec 0xd0 [  0xed r r ]
I2C START BIT
WRITE: 0xEC ACK
WRITE: 0xD0 ACK 
I2C START BIT
WRITE: 0xED ACK
READ: 0x58 
READ:  ACK 0x01 
NACK
I2C STOP BIT
I2C>
```

The command structure just follows the [datasheet][bmp280_datasheet] "5.2.2 I²C read":

> To be able to read registers,
> first the register address must be sent in write mode (slave address
111011X0).
Then either a stop or a repeated start condition must be generated. After this the slave is
addressed in read mode (RW = ‘1’) at address 111011X1, after which the slave sends out data from
auto-incremented register addresses until a NOACKM and stop condition occurs. This is depicted in
Figure 8 , where two bytes are read from register 0xF6 and 0xF7.

So, the transaction starts with the Start Condition (CLK is pulled down to the ground),
then Bus Pirate
sends a byte with the 7-bit slave address (`0x76` or `0b1110110`)
and the RW bit is set to the write mode i.e. `= 0`: `0b11101100` or `0xEC`.
Which is exactly what the Bus Pirate prints in the `(1)` address scan macro.

The address byte is followed by a control byte.
`0xD0` is the BMP280 ID register address.
And it is followed by a Start Condition.
Which tells the BMP280 that it is a read from the register,
so the chip has to prepare to read out the values of registers to the bus.
Then the Bus Pirate sends the address byte with the read mode `0xED`,
and receives the reads from the device.

I2C devices acknowledge the reception of a frame by pulling down SDA
after the payload byte
at the last (9th) bit of the frame.
A scope capture of such an ACK from the BMP280 to the `0xEC` address frame:

<img class="Figure"
alt="I2C frame with an ACK bit at the end"
src="/dir/2026-02-buspirate/i2c-frame-ack-image.jpeg"
/>

When there is nothing on the bus, the bit is not pulled, and you get a NACK bit:

<img class="Figure"
alt="I2C frame with a NACK bit at the end"
src="/dir/2026-02-buspirate/i2c-frame-nack-image.jpeg"
/>


# Conclusion

Bus Pirate is a very handy tool.
I might come back to it more in future.
This post presents a couple quick startup checks and takes a look at some basics of I2C bus.

The Sparkfun [tutorial][sparkfun_tutorial] and other resources walk through more features of the Bus Pirate.
And the BMP280 sensor has an excellent [datasheet][bmp280_datasheet].


[ian_site]: http://dangerousprototypes.com/docs/Bus_Pirate "Bus Pirate - DP"
[seeed_3p6]: https://www.seeedstudio.com/Bus-Pirate-v3-6-universal-serial-interface-p-609.html "Bus Pirate 3.6 - Seeed Studio Store"
[new_buspirate]: https://docs.buspirate.com/docs/overview/hardware/ "buspirate dot com"
[sparkfun_tutorial]: https://learn.sparkfun.com/tutorials/bus-pirate-v36a-hookup-guide/all "BusPirate 3.6a Hookup Guide - Sparkfun Learn"
[bmp280_datasheet]: https://www.bosch-sensortec.com/media/boschsensortec/downloads/datasheets/bst-bmp280-ds001.pdf "Bosch BMP280 datasheet"
[community_legacy_buspirate]: https://github.com/ElderlyPirate/Bus_Pirate "Community developed firmware for Bus Pirate version 3 and 4"

