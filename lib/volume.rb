module Volume
  STEP_SIZE = 0.05
  INITIAL = 0.9 # 0.0 .. 1.0
  DEVICE_NUMID = 1 # find the correct one with `amixer controls`
  def self.init
    @volume = INITIAL # 0.0 .. 1.0
    self.set_volume
  end
  
  def self.up
    @volume += STEP_SIZE
    @volume = 1.0 if @volume > 1.0
    self.set_volume
  end

  def self.down
    @volume -= STEP_SIZE
    @volume = 0.0 if @volume < 0.0
    self.set_volume
  end

  def self.set_volume
    percent = (@volume * 100).to_i
    `amixer cset numid=#{DEVICE_NUMID} #{percent}%`
  end
end
