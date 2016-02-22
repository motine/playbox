require_relative "gpio"

# This class encapsulates mplayer.
# When something needs to be played it forks a subprocess and runs mplayer in it.
# If a file should be played while another is still playing, the other process is sent a TERM signal.
module Player
  SOUNDS_PATH = File.expand_path("../../sounds", __FILE__)

  def self.init
    @next_tracks = Array.new(4, 1) # which track shall be played next
  end

  # checks in @next_tracks which track shall now be played.
  # it will assemble the file name after following pattern "BUTTON_TRACK.mp3" (e.g. "1_2.mp3", button one was pressed the second time)
  # if the given file does not exist, the entry for the button_no in @next_tracks will be reset to 1 and play_track will be called again
  # @param button_no [Number] determines the prefix (must be 1..4)
  def self.play_track(button_no)
    file_to_play = path_for_sound("#{button_no}_#{@next_tracks[button_no-1]}")
    if File.exist?(file_to_play)
      @next_tracks[button_no-1] += 1
      play(file_to_play)
      return
    end
    # the file did not exist, so we need to reset to 1
    @next_tracks[button_no-1] = 1
    play_track(button_no)
  end
  
  
  def self.play_boot
    self.play(self.path_for_sound("boot"))
  end
  
  def self.play_shutdown
    self.play(self.path_for_sound("shutdown"))
    sleep 5
  end

  # plays the given file_path by forking a process with mplayer.
  # if there was a previous start of such a process, it will be killed.
  def self.play(file_path)
    puts "playing #{file_path}"
    self.kill_previous
    @pid = fork do
      exec("/usr/bin/mplayer --really-quiet #{file_path}") # >/dev/null 2>/dev/null
    end
  end
  
  def self.kill_previous
    Process.kill "TERM", @pid unless @pid.nil?
  end

  def self.path_for_sound(base_file_name)
    return File.join(SOUNDS_PATH, "#{base_file_name}.mp3")
  end
end
GPIO.register_cleanup_callback { Player.kill_previous }
