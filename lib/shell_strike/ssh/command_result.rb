class ShellStrike::Ssh::CommandResult
  attr_reader :command, :exit_code, :stdout, :stderr

  def initialize(**args)
    args.each do |key, value|
      instance_variable_set("@#{key}".to_sym, value)
  end
end