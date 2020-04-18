---
layout: post
title:  "Anycubic i3 mega controller board replacement"
date:   2020-04-18 16:10:00 +0100
categories: maker
image:  /images/fulls/pcb.jpg
---


I own an [Anycubic I3 mega](https://www.amazon.de/dp/B06XDFQ3LR?tag=viddleit-21),
which can be very helpful when building, and especially when fixing stuff.
Recently, the heatbed stopped working. My guess is, that the Mosfet on the
controller board is broken. In order to get it working again quickly, I ordered
a new [controller board from Amazon](https://www.amazon.de/gp/product/B0788HM2CP?tag=viddleit-21).
Unfortunately, it was a bit more difficult to get it working then I was hoping.

In a [video on YouTube](https://www.youtube.com/watch?v=O-0fdBljgDo), Minitec 3D
explains, that the board must first be flashed with a new firmware. Therefore,
the board needs to be disconnected from power and the power source jumper needs
to be changed from "DC" to "USB".

<center><img src="/images/fulls/trigorilla-powersource-jumper.jpg" width="60%" alt="TriGorilla power source jumper"></center>

After that is changed, the board can be connected to a computer through USB, and
the firmware can be uploaded. For that, I tried to use Cura, unfortunately, it
was not finding the board. In pretty old versions of Cura (<= 15.04.06), it's
possible to select the serial port. The version is still available for
[download](http://software.ultimaker.com/cura/Ultimaker_Cura-15.04.06-Darwin.dmg).
The serial port can be selected under **File → Machine settings ...**, after
selecting the serial port, I was able to upload the new firmware by selecting
**Machine → Install custom firmware...**

The firmware I used is [Marlin-Ai3M-v1.4.6](https://github.com/davidramiro/Marlin-Ai3M/releases)
maintained by [davidramiro](https://github.com/davidramiro/Marlin-Ai3M/releases)
(Thanks a lot for that!!!).

The newer firmware is using PWM to keep the heat bed at the correct temperature.
This is putting additional stress on the heat bed mosfet and can destroy it. In
this case, I'd strongly recommend to add an [external mosfet](https://www.amazon.de/gp/product/B077HP7XX9?tag=viddleit-21)
for the heat bed.
