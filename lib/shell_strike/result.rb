class ShellStrike::Result
  # Initialises a new Result object, used to represent whether a task was successful.
  # @param success_value [Boolean] whether the action was successful.
  # @param message [String] a message explaining the result.
  # @param error_type [Symbol, nil] a symbol representing the type of failure.
  def initialize(success_value, message = '', error_type = nil)
    @success_value = success_value
    @message = message
    @error_type = error_type
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

  # @return [Symbol, nil] a symbol representing the type of error that occurred; or `nil` if #success? is true
  def error_type
    return nil if success?

    @error_type
  end
end