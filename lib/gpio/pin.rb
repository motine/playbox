module GPIO
  # Encapsulates the gpio command line tool for setting up, reading and writing pins.
  class Pin
    # pin shall be the number of the GPIO pin
    # mode may be :in, :out or :up (for pull up resistor activated)
    def initialize(pin, mode)
      # TODO argument checking
      @pin = pin
      @mode = mode
      `gpio mode #{@pin} #{mode.to_s}`
    end
    
    # will return 0 or 1 (int)
    def read
      raise "Can not read from OUT pins" if @mode == :out
      return `gpio read #{@pin}`.strip.to_i
    end

    def write(value)
      raise "Can only write 0 or 1 to pin" unless ["0", "1"].include?(value.to_s)
      raise "Can only write to OUT pins" unless @mode == :out
      return `gpio write #{@pin} #{value.to_s}`
    end
  end
end