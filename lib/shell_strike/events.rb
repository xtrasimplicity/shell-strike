require 'events'

module ShellStrike::Events
  class Emitter
    include ::Events::Emitter
  end
  private_constant :Emitter

  def self.on(event_name, &block)
    raise ShellStrike::InvalidEvent unless event_name.is_a?(Symbol)

    instance.on(event_name, &block)
  end

  protected
  
  def self.emit(event_name, *args)
    raise ShellStrike::InvalidEvent unless event_name.is_a?(Symbol)

    instance.emit(event_name, *args)
  end
    
  private

  def self.instance
    @emitter ||= Emitter.new
  end
end