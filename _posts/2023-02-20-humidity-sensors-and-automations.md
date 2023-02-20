---
layout: post
title:  How you can calculate the dew point in Home Assistant
date:   2023-02-20 02:00:01+0100
categories: homeassistant
image:  /images/fulls/humidity.jpg
---

A problem I've had a lot in the past, is high humidity at home. This caused fogged windows, and at times even
slightly wet walls. Over time, this can lead to mold, and this is something you should always avoid. The reason
for fogged windows and wet walls is the combination of high humidity inside the house, and cold windows and
walls due to colder temperatures outsinde. But what can we do about this?

There are several things that can be done in order to reduce the issue. In older buildings, the walls are often
not very well insulated, and therefore are usually much colder than the air in the room. But also blacing
furnature close to outside walls prevent the warm air of the room reaching and heating up the walls. Cold parts
of a room are always the first places where the water in the air starts to condense. So there are two things you
want to do.

1. Ensure the walls and windows are not getting too cold
2. Ensure the in-room humidity is not too high

## Keep your walls and windows warm

Of course, keeping your inside warm is always important, since it means that less heat is escaping from the inside
to the outside. This is good for your money, and the environment since it saves energy, but it's expensive and maybe
even impossible if you're just renting. So there is often not much you can do here. However, when you place
something in front of the inside of your outside wall, like a bookshelf, you might increase an existing problem.

No matter how well your house is insulated, your walls will always transmit some of the cold from the outside to 
the inside. It needs the warm air from the inside circulating alongside the walls to keep them warm. By placing
something in front of the walls, the air flow will be interrupted, and you walls will cool down even further. This
will increase the risk of condensation on the walls.

So as I already said, not much that can be done easily here.

## Keep your in-room humidity low

This is the part were I, and probably most of us, can easily improve. The most important thing that needs to be done
during sold outside temperatures is airing out the appartment on a regular basis. This can mean several times a
day. But, it's difficult to know when it's time again to open the windows and let fresh air in. For this, the easiest
solution would maybe be have a hygrometer in the rooms, showing you the relative humidity. But for me as a home
automation enthusiast, this wasn't the way to go. I wanted to know the dew point within the affected rooms in my
appartment, and I wanted to receive push notifications on my phone to remind me that I need to open the windows again.

## Homidity control with Home Assistant

In order to better understand the situation in my Apartment, I bought an infrared thermometer (like the [Bosch UniversalTemp](https://www.amazon.de/Bosch-Infrarot-Thermometer-UniversalTemp-Temperaturbereich/dp/B07T85G8BZ/?tag=viddleit-21)),
and some Zigbee temperature and humidity sensors (in my case the [SONOFF SNZB-02](https://www.amazon.de/SNZB-02-Innentemperatur-Luftfeuchtigkeitssensor-Innenthermometer-Hygrometer-Alarmfunktion/dp/B08BFW697F/?tag=viddleit-21)).
Combined with my Home Assistant installation, I was able to create some calculations, that gave me a rough
understanding of the current situation. Also, with this information I was able to create some automations for
notifying me about necessity of opening the windows for a while.

To do this, I was putting one humidity sensors in each room, close to the most critical point on the walls. Then I
monitored the measured temparature of the sensor for a while, and compared them to the temperatures I measured with the
infrared thermometer on the coldest point of the wall. This gave me a rough offset temperature between the measured
and actual temperature of the wall. Next I used the humidity and temperature from the sensor, to calculate the dew
point temperature in the room. On the german website [wetterochs](https://www.wetterochs.de/wetter/feuchte.html) you
can find a bunch of formulars, to do different humidity calculations. Here are the formulars:

```
Variables:
r = relative humidity
T = temperature in °C
TK = temperature in Kelvin (TK = T + 273.15)
TD = dew point temperature in °C
DD = vapor pressure in hPa
SDD = Saturation vapor pressure in hPa

Parameter:
a = 7.5, b = 237.3 für T >= 0
a = 7.6, b = 240.7 für T < 0 over water (dew point)
a = 9.5, b = 265.5 für T < 0 over ice (freezing temperature)

R* = 8314.3 J/(kmol*K) (universal gas const.)
mw = 18.016 kg/kmol (molecular weight of water vapor)
AF = absolute humidity in g water vapor per m3 air

Formula:
SDD(T) = 6.1078 * 10^((a*T)/(b+T))
DD(r,T) = r/100 * SDD(T)
r(T,TD) = 100 * SDD(TD) / SDD(T)
TD(r,T) = b*v/(a-v) mit v(r,T) = log10(DD(r,T)/6.1078)
AF(r,TK) = 10^5 * mw/R* * DD(r,T)/TK; AF(TD,TK) = 10^5 * mw/R* * SDD(TD)/TK
```

From the formulars above, we can now create a single formular to calculate the dew point temperature. Since
we're inside, we can safely assume, that the temperature is over 0°C. Therefore, `a = 7.5` and `b = 237.3`.

```
SDD(T) = 6.1078 * 10^((7.5*T)/(237.3+T))
v(r,T) = log10(DD(r,T)/6.1078) = log10(r/100 * SDD(T)/6.1078) = log10(r/100 * 10^((7.5*T)/(237.3+T)))
TD(r, T) = b*v/(a-v) = 237.3*v(r,T)/(7.5-(v(r,T))) = 2237.3*(log10(r/100 * 10^((7.5*T)/(237.3+T))))/(7.5-(log10(r/100 * 10^((7.5*T)/(237.3+T)))))

TD(r, T) = 237.3 * log10(r / 100 * 10^((7.5 * T) / (237.3 + T))) / (7.5 - log10(r / 100 * 10^((7.5 * T) / (237.3 + T))))
```

Now, we can turn this formula into a template sensor for Home Assistant:

```
# configuration.yaml
sensors:
  - platform: template
    sensors:
      dew_point_living_room:
        friendly_name: "Dew point living room"
        unit_of_measurement: "°C"
        value_template: >-
          {% set t = states('sensor.living_area_temperature') | float %}
          {% set r = states('sensor.living_area_humidity') | float %}
          {{237.3*log(r/100 * 10**((7.5*t)/(237.3+t)))/(7.5-log(r/100 * 10**((7.5*t)/(237.3+t)))) | round(1)}}
```

FALSCH!!!