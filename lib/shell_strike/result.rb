class ShellStrike::Result
  # Initialises a new Result object, used to represent whether a task was successful.
  # @param success_value [Boolean] whether the action was successful.
  # @param message [String] a message explaining the result.
  def initialize(success_value, message = '')
    @success_value = success_value
    @message = message
  end

  # Whether the success_value is set to true
  def success?
    @success_value
  end

  def valid?
    success?
  end

  # @return [String] a message explaining the result.
  def message
    @message
  end
end