require 'thread'
Thread.abort_on_exception=true

module GPIO
  # Uses Pin to query the Pin regularly.
  # It fires the block given to handler when the value of the pin changed.
  class Button < Pin
    # pin shall be the number of the GPIO pin
    # handler shall be a block taking no arguments.
    def initialize(pin, &handler)
      super(pin, :up)
      @handler = handler
      @last_val = 1
      self.start_watch
      GPIO.register_cleanup_callback { self.stop_watch }
    end
    
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
    
    def down?
      return self.read == 0
    end
    
    def up?
      return !self.down?
    end
    
    def stop_watch
      @watch_thread.kill
    end
  end
end