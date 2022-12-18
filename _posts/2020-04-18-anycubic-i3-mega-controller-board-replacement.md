---
layout: post
title:  "Anycubic i3 mega controller board replacement"
date:   2020-04-18 16:10:00 +0100
categories: maker
image:  /images/fulls/pcb.jpg
---

Recently, the heatbed of my beloved [Anycubic I3 mega](https://www.amazon.de/dp/B06XDFQ3LR?tag=viddleit-21)
stopped working. The 3d printer is a tool I use quite often to mak replacement
parts, build enclosures for small IoT projects or to create helpful tools I can
use for woodworking. When checking the controller board, I quickly found, that the
mosfet controlling the heatbed was defect. Since I wanted to get my printer running
again quickly, and I didn't have a matching mosfet at hand, I decided to order a new
[controller board from Amazon](https://www.amazon.de/gp/product/B0788HM2CP?tag=viddleit-21)
instead of trying to replace it first. Unfortunately, it was a bit more difficult
to get it working then I was hoping for.

In a [video on YouTube](https://www.youtube.com/watch?v=O-0fdBljgDo) from Minitec 3D
I found, that the board must first be flashed with a new firmware first. Therefore,
the board was disconnected from power and the power source jumper needed to be changed
from "DC" to "USB".

<center><img src="/images/fulls/trigorilla-powersource-jumper.jpg" width="60%" alt="TriGorilla power source jumper"></center>

Afterwards, the board was connected to a computer through USB, and the firmware
could be uploaded. However, it wasn't working with Cura out of the box, but after
downloading pretty old versions of Cura (<= 15.04.06), it was
possible to select the serial port. The version is still available for
[download](http://software.ultimaker.com/cura/Ultimaker_Cura-15.04.06-Darwin.dmg).
The serial port can be selected under **File → Machine settings ...**, after
that, I was able to upload the new firmware by selecting **Machine → Install custom firmware...**

I used [Marlin-Ai3M-v1.4.6](https://github.com/davidramiro/Marlin-Ai3M/releases) maintained by davidramiro
(Thanks a lot for that!!!). Since the newer firmware is using PWM to keep the
heatbed at the correct temperature, this is putting additional stress on the
heatbed mosfet and can destroy it. If you do this as well, I strongly recommend to
add an [external mosfet](https://www.amazon.de/gp/product/B077HP7XX9?tag=viddleit-21)
for the heatbed to your printer.
