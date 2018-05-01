require 'net/ssh'
require 'socket'

module ShellStrike::Ssh
  class << self
    def host_listening?(host)
      result = :success

      begin
        attempt_connection(host, 'fake_username', 'fake_password')
      rescue Errno::EHOSTUNREACH
        result = :unreachable
      rescue Net::SSH::ConnectionTimeout
        result = :timeout
      end
      
      !([:unreachable, :timeout].include?(result))
    end

    def valid_credentials?(host, username, password)
      return false unless host_listening?(host)

      begin
        attempt_connection(host, username, password)
        true
      rescue Net::SSH::Exception, Errno::EHOSTUNREACH
        false
      end
    end

    # TODO: Add comment describing args, raises, etc
    def execute_command(host, username, password, command)
      raise HostUnreachableError unless host_listening?(host)
      raise InvalidCredentialsError unless valid_credentials?(host, username, password)

      CommandResult.new(command, 0, '', '')
    end
  end

  private

  def self.attempt_connection(host, username, password)
    Net::SSH.start(host.host, username, password: password, port: host.port, non_interactive: true, timeout: host.connection_timeout)
  end
end


require_relative 'ssh/command_result'
require_relative 'ssh/errors'