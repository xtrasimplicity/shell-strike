require "shell_strike/version"

class ShellStrike
  attr_reader :hosts, :usernames, :passwords, :global_actions

  def initialize(hosts, usernames, passwords, global_actions = [])
    @hosts = hosts
    @usernames = usernames
    @passwords = passwords
    @global_actions = global_actions
  end

end
