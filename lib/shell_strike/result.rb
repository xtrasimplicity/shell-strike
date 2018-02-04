class ShellStrike::Result
  # Initialises a new Result object, used to represent whether a task was successful.
  # @param success_value [Boolean] whether the action was successful.
  # @param message [String] a message explaining the result.
  # @param exception [Error, nil] an exception object with further information regarding the failure.
  def initialize(success_value, message = '', exception = nil)
    @success_value = success_value
    @message = message
    @exception = exception
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

  # @return [Error, nil] an exception object with further information regarding the failure.
  def exception
    @exception
  end
end