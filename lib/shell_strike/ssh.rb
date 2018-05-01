require 'net/ssh'
require 'socket'

module ShellStrike::Ssh
  class << self
    def host_listening?(host)
      connection_result = test_connection(host, 'fake_username', 'fake_password')

      !([:unreachable, :timeout].include?(connection_result))
    end
  end

  private

  def self.test_connection(host, username, password)
    result = :success

    begin
      Net::SSH.start(host.host, username, password: password, port: host.port, non_interactive: true, timeout: host.connection_timeout)
    rescue Errno::EHOSTUNREACH
      result = :unreachable
    rescue Net::SSH::ConnectionTimeout
      result = :timeout
    end

    result
  end
end