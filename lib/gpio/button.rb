require 'thread'
Thread.abort_on_exception=true

module GPIO
  # Uses Pin to query the Pin regularly.
  # It fires the block given to handler when the value of the pin changed.
  # This class is based on PIN, which in itself is based on a command line call
  # This is bad, but I wanted to try this once. Please see note in README.md
  class Button < Pin
    # @param pin [Number] shall be the number of the GPIO pin
    # @yield handler [] block called with no arguments when the button is pressed.
    def initialize(pin, &handler)
      super(pin, :up)
      @handler = handler
      @last_val = 1
      self.start_watch
      GPIO.register_cleanup_callback { self.stop_watch }
    end
    
    # Starts a thread to regularly check for button presses.
    def start_watch
      @watch_thread = Thread.new do # this is highly inefficient
        loop do
          cur_val = self.read
          if cur_val != @last_val
            direction = (cur_val == 0) ? :down : :up
            @handler.call(direction) if direction == :down
            @last_val = cur_val
          end
          sleep 0.05
        end
      end
    end
    
    # Returns true when the button is down.
    def down?
      return self.read == 0
    end
    
    def up?
      return !self.down?
    end
    
    # Stops the thread started with `start_watch`.
    def stop_watch
      @watch_thread.kill
    end
  end
end