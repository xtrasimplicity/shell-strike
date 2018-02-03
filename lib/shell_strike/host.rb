class ShellStrike::Host
  attr_reader :host, :port, :connection_timeout, :actions
  
  # Initialises a new Host object.
  # @param host [String] the hostname or IP address of the host.
  # @param port [Number] the port number to use for the connection.
  # @param connection_timeout [Number] how long to wait before timing out connection attempts (in seconds).
  # @param actions [Array<String>] Shell commands to execute against the server, upon successful connection. Interactive commands are NOT supported.
  def initialize(host, port = 22, connection_timeout = 30, actions = [])
    @host = host
    @port = port
    @connection_timeout = connection_timeout
    @actions = actions
  end

  # Whether the host is able to be reached on the specified port.
  def reachable?
    begin
      Socket.tcp(@host, @port, connect_timeout: @connection_timeout) { |s| s.close }
      return true
    rescue
      return false  
    end
  end

  # Tests the specified username and password.
  # @param username [String] the username to test.
  # @param password [String] the password to test.
  # @return [Result] a result object indicating whether the credentials are valid
  def test_credentials(username, password)
    valid = false
    message = ''

    begin
      Net::SSH.start(@host, username, password: password, port: @port, non_interactive: true, timeout: @connection_timeout)

      valid = true
    rescue Net::SSH::AuthenticationFailed
      message = 'Invalid Credentials'
    rescue Net::SSH::ConnectionTimeout
      message = "Connection timed out whilst attempting to connect to #{@host} on port #{@port}"
    rescue Net::SSH::Exception => e
      message = "An unexpected error occurred whilst connecting to #{@host} on port #{@port} with username #{username} and password #{@password}: #{e.message}"
    rescue Errno::EHOSTUNREACH => e
      message = "Unable to connect to #{@host}: #{e.message}"
    end

    ShellStrike::Result.new(valid, message)
  end
end