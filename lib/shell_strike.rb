require "shell_strike/version"
require "shell_strike/ssh"
require "shell_strike/exceptions"
require "shell_strike/result"
require "shell_strike/host"

class ShellStrike
  attr_reader :hosts, :usernames, :passwords, :global_actions

  # Initialises a new ShellStrike instance
  # @param hosts [Array<Host>] an array of Hosts
  # @param usernames [Array<String>] an array of usernames to test; a username dictionary.
  # @param passwords [Array<String>] an array of passwords to test; a password dictionary.
  # @param global_actions [Array<String>] an array of shell commands to execute against every host. Interactive shell commands are NOT supported.
  def initialize(hosts, usernames, passwords, global_actions = [])
    raise HostsNotDefined if hosts.nil? || hosts.empty?
    raise UsernamesNotDefined if usernames.nil? || usernames.empty?
    raise PasswordsNotDefined if passwords.nil? || passwords.empty?

    @hosts = hosts
    @usernames = usernames
    @passwords = passwords
    @global_actions = global_actions
  end

  # Identifies valid credentials for each host and populates the `identified_credentials`, `failed_hosts` and `unreachable_hosts` arrays. 
  def identify_credentials!
    @hosts.each do |host|
      credential_failure_count = 0

      username_password_combinations.each do |username, password|
        auth_result = host.test_credentials(username, password)

        if auth_result.valid?
          store_valid_credentials(host, username, password)
          next
        else
          case auth_result.error_type
            when :authentication_failure
              credential_failure_count += 1
            when :host_unreachable, :connection_timeout, :unexpected_error
              store_unreachable_host(host, auth_result.message)
              break
          end
        end
      end

      store_failed_host(host) if credential_failure_count == username_password_combinations.length
    end
  end

  

  # A hash of hosts and their valid credentials.
  # @return A hash of Host URIs and their valid credentials.
  # @example
  #   { '192.168.1.100:22' => ['admin', 'password'] }
  def identified_credentials
    @identified_credentials ||= {}
  end

  # A hash of hosts which were unreachable.
  # @return A hash of Host objects and their error messages.
  # @example
  #     #<ShellStrike::Host:*> => 'Unable to connect to *. No route to host'
  def unreachable_hosts
    @unreachable_hosts ||= {}
  end

  # An array of hosts for which valid credentials were not able to be identified.
  # @return An array of Host objects
  def failed_hosts
    @failed_hosts ||= []
  end

  private

  # Creates an array of username and password combinations, using the previously supplied usernames and passwords.
  # @return An array of (yet to be validated!) username and password combinations
  # @example
  #   [ ['root', 'letmein'], ['admin', 'password'] ]
  def username_password_combinations
    @usernames.product(@passwords)
  end

  # Stores valid credentials into the #identified_credentials array
  # @param host [Host] The host object for which to store the valid credentials
  # @param username [String] The valid username for this host
  # @param password [String] The valid password for this host
  def store_valid_credentials(host, username, password)
    identified_credentials[host.to_uri] = [] unless identified_credentials.has_key? host.to_uri
    identified_credentials[host.to_uri] << [username, password]
  end

  # Stores the unreachable host into the unreachable hosts array
  # @param host [Host] The unreachable host.
  # @param message [String] A message with further information about the unreachability of the host.
  def store_unreachable_host(host, message)
    unreachable_hosts[host.to_uri] = message
  end

  # Stores the host (for which no valid credentials could be identified) into the failed hosts array.
  # @param host [Host] the host for which no valid credentials could be identified.
  def store_failed_host(host)
    failed_hosts << host
  end
end
