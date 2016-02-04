#!/usr/bin/env ruby
require_relative "lib/gpio"
require_relative "lib/mplayer"
require_relative "lib/volume"

# make the LED turn on when the program starts and turn off when it ends
led = GPIO::Pin.new(6, :out)
led.write(1)
GPIO.register_cleanup_callback { led.write(0) }

Volume.init

# press right red button
def volume_up
  puts "increasing volume"
  Volume.up
end
# press left red button
def volume_down
  puts "decreasing volume"
  Volume.down
end

# no will be 1..4
def play(no)
  file_to_play = File.expand_path("../sounds/#{no}.mp3", __FILE__)
  puts "playing #{file_to_play}"
  MPlayer.play(file_to_play)
end

# press right then left red button
def shutdown
  `sudo shutdown -h 0`
  GPIO.stop
end

volup = GPIO::Button.new(0) do
  volume_up
end

GPIO::Button.new(1) do
  volume_down
  shutdown if volup.down?
end

4.times do |i|
  GPIO::Button.new(2+i) do
    play(4-i)
  end
end

# make sure to shutdown nicely when the service goes down (or CTRL-C is pressed)
Signal.trap("INT") do
  shutdown
end
Signal.trap("TERM") do
  shutdown
end

puts "started..."
GPIO.wait