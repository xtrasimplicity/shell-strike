require "net/ssh"

require "shell_strike/version"
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

  def perform_attack
    combinations = @usernames.product(@passwords)

    @hosts.each do |host|
      host_failure_count = 0
      
      combinations.each do |username, password|
        authentication = host.test_credentials(username, password)

        if authentication.valid?
          identified_credentials[host.to_uri] = [username, password]
        elsif authentication.exception.nil?
          host_failure_count += 1
        else
          unreachable_hosts[host.to_uri] = authentication.message
          break
        end
      end

      failed_hosts << host if host_failure_count == combinations.length

    end
  end

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
end
