class ShellStrike::Ssh::HostUnreachableError < StandardError
end

class ShellStrike::Ssh::InvalidCredentialsError < StandardError
end

class ShellStrike::Ssh::CommandExecutionFailureError < StandardError; end