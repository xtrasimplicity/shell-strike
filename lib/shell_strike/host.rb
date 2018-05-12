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

  # Returns whether the specified credentials are valid
  # @param username [String] The username to test.
  # @param password [String] The password to test.
  # @return [Boolean] Whether the credentials are valid.
  def valid_credentials?(username, password)
    ShellStrike::Ssh.valid_credentials?(self, username, password)
  end

  # Executes the actions defined in @actions and `supplementary_actions` against the host.
  # @param username [String] The username to use to authenticate with the host.
  # @param password [String] The password to use to authenticate with the host.
  # @param supplementary_actions [Array<string>] Additional commands to run against the host.
  # @return [Array<ShellStrike::Ssh::CommandResult] The results for each command.
  def execute_actions(username, password, supplementary_actions = [])
    all_actions = @actions.concat(supplementary_actions)

    return [] if all_actions.empty?

    action_results = []

    all_actions.each do |action|
      action_results << build_authentication_failure_result(action) and next unless valid_credentials?(username, password)
    end

    action_results
  end

  private

  def build_authentication_failure_result(action)
    ShellStrike::Ssh::CommandResult.new(
      command: action,
      stdout: '',
      stderr: 'Unable to authenticate with the host. The supplied credentials are invalid.'
    )
  end

end