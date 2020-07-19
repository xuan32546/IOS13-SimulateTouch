# IOS13-SimulateTouch
iOS 11.0 - 13.6 system level touch simulation iOS13模拟点击
Jailbroken device required

## Features
1. Multitouching supported (no other library you can find supports multitouching).
2. Programmable. Control scripts can be programmed with all the programming language you desire.
3. Instant controlling supported. The ios device can be controlled with no latency from other devices/computers.
4. System level touch simulation (will not inject to any process).

## Installation
1. Open Cydia - Sources - Edit - Add - http://47.114.83.227 ("http" instead of "https"!!! Please double check this.)
2. Install ZJXTouchSimulation tweak
3. Done

## Usage
1. After installation, the tweak will start listening at port 6000.
2. Use socket to send touch data field to the tweak

data field should always be decimal digits, specified below
![alt text](https://raw.githubusercontent.com/xuan32546/IOS13-SimulateTouch/master/img/event-data-digit.png)

`Event Count`(1 digit): Specify the count of the single events. If you have multiple events to send at the same time, just increase the event count and append events to the data.

`Type`(1 digit): Specify the type of the single event. 

Supported event type:


 | Event   | Flag | Description  |
|:--------:|:-------------:|:------------:|
| Touch Up      | 0      | Specify the event as a touch up event |
| Touch Down    | 1      | Specify the event as a touch down event |
| Touch Move    | 2      | Specify the event as a touch move event (move the finger) |
| Set Size      | 9      | Set screen size (required!! Will be explained below) |

`Touch Index`(2 digits): Apple supports multitouch, so you have to specify the finger index when posting touching events. The range of finger index is 1-20 (0 is reserved, don't use 0 as finger index). 

`x Coordinate`(5 digits): The x coordinate of the place you want to touch. The first 4 digit is for integer part while the last one is for decimal part. For example, if you want to touch (123.4, 2432.1) on the screen, you should fill "01234" for this.

`y Coordinate`(5 digits): The y coordinate of the place you want to touch. The first 4 digit is for integer part while the last one is for decimal part. For example, if you want to touch (123.4, 2432.1) on the screen, you should fill "24321" for this.
