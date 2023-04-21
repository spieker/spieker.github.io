---
layout: post
title:  "Smart home: keep the simple simple"
date:   2023-04-19 14:11:23 +0200
categories: knx home-assistant
image:  /images/fulls/smart-home.jpg
---

Several year ago, I read the book "The humane interface" from "Jef Raskin". The main thing that stuck to me was the first chapter "keep the simple simple". Setting up our smart home, this is one of the things I was keeping in mind when building automations. The backbone of our wiring is KNX, and we mainly use buttons resembling good old light switches. From the optics they're pretty plain, and their usability is rather intuitive. However, thanks to KNX and Home Assistant, these switches can be extended to create additional useful functionality.

## Using KNX telegrams in Home Assistant

A big plus of KNX is, that it's pretty failure tolerant. By keeping the basic functionality of a button (like switching a light on and off) fully implemented in KNX, we can ensure that this keeps working even if there is an issue with the home server. But, in order to exend the basic functionality of the butten, the home server can listen and react to the KNX telegrams sent by the button when tapped.

In our case, we use Home Assistant as the home server, and KNX telegrams can be imported as events into the system. For this, each KNX group address that should be monitored, needs to be configured as an event in Home Assistant's KNX configuration (see [KNX events](https://www.home-assistant.io/integrations/knx/#events)). For the example in this post, we'll be looking at telegrams sent to the group address `1/1/16`. The KNX event configuration in your for this example `configuration.yaml` should look like this:

```yaml
knx:
  event:
    - address: "1/1/16"
  light:
    - name: "Ceiling light kids room"
      address: "1/1/16"
      state_address: "1/1/17"
```

This configuration provides a light entity in Home Assistant, and also tells it to listen to telegrams on address `1/1/16` and turn them into an event within Home Assistant.

## Switch all off

An additional functionaly of our main light buttons is, that a double tap is switching off all lights and media playing in this room. For this, automations in our home automation server (Home Assistant) is monitoring KNX events of the different buttons. As soon as an off event is fired from the button, a timeout is started, waiting for a second "off" event to happen within a given amount of time. In case the second event is happening in time, Home Assistant is executing additional actions. In out case this is switching off everything within the room.

```yaml
alias: "Switch off room"
description: ""
trigger:
  - platform: event
    event_type: knx_event
    event_data:
      destination: '1/1/16'  # The group address to listen to
      data: 0  # Only listen to events with an "off" payload
condition: []
action:
  # This is waiting for a second trigger on the address "1/1/16" with an "off" payload
  - wait_for_trigger:
      - platform: event
        event_type: knx_event
        event_data:
          destination: '1/1/16'
          data: 0
    continue_on_timeout: false  # Do not continue if the second event don't happen in time
    timeout: 0.3  # Wait for 0.3 seconds for the second event to occur

  # Switch off all lights in this room
  - service: light.turn_off
    data: {}
    target:
      area_id: kids_room

  # Switch off all media playing in this room
  - service: media_player.media_pause
    data: {}
    target:
      area_id: kids_room

mode: single
```

Ofcourse, when using this pattern in different rooms, it makes sense to put this into blueprint. In a later post I'll share how to do that.
