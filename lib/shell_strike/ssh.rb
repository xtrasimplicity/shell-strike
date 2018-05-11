require 'net/ssh'
require 'socket'

module ShellStrike::Ssh
  class << self
    def check_host_reachable(host)
      reachable = false
      explanation = nil

      begin
        establish_connection(host, 'fake_username', 'fake_password')
        reachable = true
      rescue Net::SSH::AuthenticationFailed
        reachable = true
      rescue Net::SSH::ConnectionTimeout
        explanation = :timeout
      rescue Errno::EHOSTUNREACH
        explanation = :unreachable
      rescue Net::SSH::Exception
        explanation = :unexpected_error
      end
      
      [reachable, explanation]
    end

    def valid_credentials?(host, username, password)
      return false unless check_host_reachable(host)[0]

      begin
        establish_connection(host, username, password)
        true
      rescue Net::SSH::Exception, Errno::EHOSTUNREACH
        false
      end
    end

    # Executes the specified command against the specified host.
    # @param host [ShellStrike::Host] The host to execute the command against.
    # @param username [String] The username to use to establish the connection.
    # @param password [String] The password to use to establish the connection.
    # @param command [String] The command to run against the remote host.
    # @raise [HostUnreachableError] If a connection to the host could not be established.
    # @raise [InvalidCredentialsError] If the credentials supplied are invalid.
    # @return [CommandResult] The result of the command's execution.
    def execute_command(host, username, password, command)
      raise HostUnreachableError unless check_host_reachable(host)[0]
      raise InvalidCredentialsError unless valid_credentials?(host, username, password)

      exit_code = 1
      stdout_text = ''
      stderr_text = ''


      establish_connection(host, username, password) do |ssh|
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

  # Establishes a connection to the specified host.
  # @param host [ShellStrike::Host] The host to connect to.
  # @param username [String] The username to connect using.
  # @param password [String] The password to connect using.
  # @yieldparam [Net::SSH::Connection::Session] block The block to execute against the established SSH connection.
  def self.establish_connection(host, username, password, &block)
    Net::SSH::start(host.host, username, password: password, port: host.port, non_interactive: true, timeout: host.connection_timeout, &block)
  end
end


require_relative 'ssh/command_result'
require_relative 'ssh/errors'