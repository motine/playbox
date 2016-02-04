# playbox
## Installation


Setup Raspberry Pi with [setup wifi](https://learn.adafruit.com/adafruits-raspberry-pi-lesson-3-network-setup/setting-up-wifi-with-occidentalis)
find the IP with ifconfig (see wlan0)
Also make sure to run `raspi-config` and extend the filesystem.

```bash
sudo aptitude update
sudo aptitude install mplayer ruby-dev
sudo gem install bundler
# check out the code
bundler install
./playbox.rb

# install the service
sudo cp systemd/playbox.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable playbox
# start testing
sudo systemctl start playbox
sudo systemctl stop playbox
```

## Stuff

wget https://upload.wikimedia.org/wikipedia/commons/9/96/Beethoven_Moonlight_sonata_sequenced.ogg
wget http://download.wavetlan.com/SVV/Media/HTTP/WAV/Media-Convert/Media-Convert_test2_PCM_Mono_VBR_8SS_48000Hz.wav

amixer controls # find the route
amixer cset numid=3 1 # set to the the microphone jack

aplay ...wav

alsamixer


PinOut
https://www.element14.com/community/servlet/JiveServlet/previewBody/73950-102-4-309126/GPIO_Pi2.png?01AD=3BUVhNU8IlTFPkE0Olr7klHnCIgN9ebNH8yLA36nhHGcY9tfoMdeL6g&01RI=3606EE1B660EB0A&01NA=


check with watch gpio readall
2..5 - white
0..1 - red
6 - led

```bash
gpio mode 0 up
gpio mode 0..5 up
gpio mode 6 out
gpio write 6 1

# ask to export the pin
echo 1 > /sys/class/gpio/export # Export/Unexport pins via the /sys/class/gpio interface, where they will then be available to user programs (that then do not need to be run as root or with sudo)

```


https://www.kernel.org/doc/Documentation/gpio/sysfs.txt

thanks to the great work of: https://github.com/WiringPi/WiringPi (i read the code for better understanding)
also thanks to [...](https://github.com/jwhitehorn/pi_piper/blob/develop/lib/pi_piper/bcm2835.rb)





## why gpio shell command

i had a hard time to figure out

```ruby
#!/usr/bin/env ruby
# if you get "Device or resource busy", run: sudo gpio unexportall
`gpio unexportall` # fix unclean exit of pi_piper
require 'rubygems'
require 'pi_piper'
# info here: https://github.com/jwhitehorn/pi_piper

PiPiper::watch pin: 18, pull: :up, trigger: :falling do # did not enable the pull up resistor
  puts "Volume Down"
end
```

```ruby
#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'wiringpi2'

TEST_PINS = (0..10).to_a
io = WiringPi::GPIO.new do |gpio|
  # gpio.pin_mode(0, WiringPi::OUTPUT)
  TEST_PINS.each do |pin|
    gpio.pull_up_dn_control(pin, WiringPi::PUD_UP) # would not pull up
    gpio.pin_mode(pin, WiringPi::INPUT)
  end
end
100.times do
  state = TEST_PINS.collect { |pin| io.digital_read(pin) }
  p state
  io.delay(100)
end
```
