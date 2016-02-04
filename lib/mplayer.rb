require_relative "gpio"

module MPlayer
  def self.play(file_path)
    self.kill_previous
    @pid = fork do
      exec "/usr/bin/mplayer --really-quiet #{file_path}" # >/dev/null 2>/dev/null
    end
  end
  
  def self.kill_previous
    Process.kill "TERM", @pid unless @pid.nil?
  end
  # # you have to wait for its termination, otherwise it will become a zombie process
  # # (or you can use Process.detach)
  # Process.wait pid
end
GPIO.register_cleanup_callback { MPlayer.kill_previous }