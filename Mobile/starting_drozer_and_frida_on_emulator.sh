#!/bin/bash
## Frida
adb shell /data/local/frida &
## Drozer
### Starting a Session
adb forward tcp:31415 tcp:31415
### Connecting to the Console
drozer console connect
