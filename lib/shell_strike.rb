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
      # TODO: Handle unreachable hosts, failures, etc.

      combinations.each do |username, password|
        if host.test_credentials(username, password).valid?
          identified_credentials[host.to_uri] = [username, password]
        end
      end
    end
  end

  def identified_credentials
    @identified_credentials ||= {}
  end
end
