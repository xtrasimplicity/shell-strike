module ShellStrike::Events
  def self.on(event_name, &block)
    raise ShellStrike::InvalidEvent unless event_name.is_a?(Symbol)

    self.listeners[event_name] ||= []
    self.listeners[event_name] << block
  end

  protected
  
  def self.emit(event_name, *args)
    raise ShellStrike::InvalidEvent unless event_name.is_a?(Symbol)
    return unless self.listeners[event_name].respond_to? :each

    self.listeners[event_name].each { |e| e.call(*args) }
  end

  private

  def self.listeners
    @listeners ||= {}
  end
end