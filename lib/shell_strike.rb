require "shell_strike/version"
require "shell_strike/exceptions"

class ShellStrike
  attr_reader :hosts, :usernames, :passwords, :global_actions

  def initialize(hosts, usernames, passwords, global_actions = [])
    raise HostsNotDefined if hosts.nil? || hosts.empty?
    raise UsernamesNotDefined if usernames.nil? || usernames.empty?
    raise PasswordsNotDefined if passwords.nil? || passwords.empty?

    @hosts = hosts
    @usernames = usernames
    @passwords = passwords
    @global_actions = global_actions
  end

end
