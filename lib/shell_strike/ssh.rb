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

      exit_code = 1
      stdout_text = ''
      stderr_text = ''


      Net::SSH::start(host.host, username, password: password, port: host.port, non_interactive: true, timeout: host.connection_timeout) do |ssh|

        ssh.open_channel do |channel|
          channel.exec(command) do |ch, success|
            raise CommandExecutionFailureError unless success

            # Process the stdout stream
            ch.on_data do |_, stdout_buf|
              stdout_text << stdout_buf.read
            end

            # Process the stderr stream
            ch.on_extended_data do |_, stderr_buf|
              stderr_text << stderr_buf.read
            end

            ch.on_request('exit-status') do |_, status|
              exit_code = status.read_long
            end
          end

          channel.wait # Make sure we don't close the channel until the command has completed
        end
      end

      # Split the output streams at each linefeed
      stdout_arr = stdout_text.split("\n")
      stderr_arr = stderr_text.split("\n")

      CommandResult.new(command: command, exit_code: exit_code, stdout: stdout_arr, stderr: stderr_arr)
    end
  end

  private

  def self.attempt_connection(host, username, password)
    Net::SSH.start(host.host, username, password: password, port: host.port, non_interactive: true, timeout: host.connection_timeout)
  end
end


require_relative 'ssh/command_result'
require_relative 'ssh/errors'