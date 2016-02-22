#!/usr/bin/env ruby

# PLEASE NOTE:
# I wanted to try something out here:
# In this project I use almost exclusivly shell calls to perform external actions.
# This is usually not my style, but I wanted to see what the downsides are.
# I must say there were not so many, except that I have to spwan a new thread for each button.
# This and the constant polling is quite heavy in the performance. Apart from this, it works quite stable.

require_relative "lib/gpio"
require_relative "lib/mplayer"
require_relative "lib/volume"

SOUNDS_PATH = File.expand_path("../sounds", __FILE__)

def get_path_for_sound(base_file_name)
  return File.join(SOUNDS_PATH, "#{base_file_name}.mp3")
end

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

$next_tracks = Array.new(4,1) # which track shall be played next
# checks in $next_tracks which track shall now be played.
# it will assemble the file name after following pattern "BUTTON_TRACK.mp3" (e.g. "1_2.mp3", button one was pressed the second time)
# if the given file does not exist, the entry for the button_no in $next_tracks will be reset to 1 and play_track will be called again
# no will be 1..4
def play_track(button_no)
  file_to_play = get_path_for_sound("#{button_no}_#{$next_tracks[button_no-1]}")
  if File.exist?(file_to_play)
    play(file_to_play)
    return
  end
  # the file did not exist, so we need to reset to 1
  $next_tracks[button_no-1] = 1
  play_track(button_no)
end

# play will append mp3
def play(file_name)
  puts "playing #{file_name}"
  MPlayer.play(file_name)
end

# press right then left red button
def shutdown
  play(get_path_for_sound("shutdown"))
  sleep 5
  `sudo shutdown -h 0`
  cleanup
end

def cleanup
  GPIO.stop
end

# actually hook up the buttons
volup = GPIO::Button.new(0) do
  volume_up
end

GPIO::Button.new(1) do
  volume_down
  shutdown if volup.down?
end

4.times do |i|
  GPIO::Button.new(2+i) do
    play_track(4-i)
  end
end

# make sure to shutdown nicely when the service goes down (or CTRL-C is pressed)
Signal.trap("INT") do
  cleanup
end
Signal.trap("TERM") do
  cleanup
end

puts "started..."
play(get_path_for_sound("boot"))
GPIO.wait