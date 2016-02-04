require 'thread'
Thread.abort_on_exception=true

module GPIO
  # Blocks registered here will be called after stop was called
  def self.register_cleanup_callback(&block)
    @cleanup_callbacks ||= []
    @cleanup_callbacks << block
  end
  
  # calls all blocks given to register_cleanup_callback
  def self.cleanup
    return if @cleanup_callbacks.nil?
    @cleanup_callbacks.each do |block|
      block.call
    end
  end
  
  # will wait/block forever (unless stop was called)
  # After stop was called, cleanup is called
  def self.wait
    @terminate = false
    @wait_loop = Thread.new do
      while !@terminate
        sleep 0.1
      end
    end
    @wait_loop.join
    self.cleanup
  end
  
  # tells the wait-ing loop to terminate (and clean up)
  def self.stop
    @terminate = true
  end
end

require_relative 'gpio/pin'
require_relative 'gpio/button'
