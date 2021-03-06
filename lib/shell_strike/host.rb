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

  # Returns the current host's address in URI form.
  # @return [String] the current host's address in URI form. (host:port)
  # @example 
  #   192.168.1.200:22
  #   172.20.16.20:200
  #   example.com:22
  def to_uri
    "#{self.host}:#{self.port}"
  end
end