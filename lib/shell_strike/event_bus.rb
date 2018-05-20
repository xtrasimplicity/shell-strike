class ShellStrike::EventBus
  def on(event_name, &block)
    raise ShellStrike::InvalidEvent unless event_name.is_a?(Symbol)

    listeners[event_name] ||= []
    listeners[event_name] << block
  end
  
  def emit(event_name, *args)
    raise ShellStrike::InvalidEvent unless event_name.is_a?(Symbol)
    return unless listeners[event_name].respond_to? :each

    listeners[event_name].each { |e| e.call(*args) }
  end

  private

  def listeners
    @listeners ||= {}
  end
end