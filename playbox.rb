#!/usr/bin/env ruby

# PLEASE NOTE:
# I wanted to try something out here:
# In this project I use almost exclusivly shell calls to perform external actions.
# This is usually not my style, but I wanted to see what the downsides are.
# I must say there were not so many, except that I have to spwan a new thread for each button.
# This and the constant polling is quite heavy in the performance. Apart from this, it works quite stable.

require_relative "lib/gpio"
require_relative "lib/player"
require_relative "lib/volume"

# make the LED turn on when the program starts and turn off when it ends
led = GPIO::Pin.new(6, :out)
led.write(1)
GPIO.register_cleanup_callback { led.write(0) }

Volume.init
Player.init

def cleanup
  GPIO.stop
end

# actually hook up the buttons
volup = GPIO::Button.new(0) do
  puts "increasing volume"
  Volume.up
end

GPIO::Button.new(1) do
  if volup.down? # we are shutting down...
    Player.play_shutdown
    `sudo shutdown -h 0`
    cleanup
    next
  end
  puts "decreasing volume"
  Volume.down
end

4.times do |i|
  GPIO::Button.new(2+i) do
    Player.play_track(4-i)
  end
end

# make sure to shutdown nicely when the service goes down (or CTRL-C is pressed)
["INT", "TERM"].each do |signal|
  Signal.trap(signal) do
    cleanup
  end
end

puts "started..."
Player.play_boot
GPIO.wait