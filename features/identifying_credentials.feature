Feature: Credential Identification
  Scenario: Identifying credentials when a host is online
    Given There is an SSH server running on '192.168.1.100':22
    And the server has a valid username of 'admin' with a password of 'letmein'
    When I run the following code
    """
      usernames = ['root', 'admin']
      passwords = ['letmein', 'password']
      hosts = [
        ShellStrike::Host.new('192.168.1.101'),
        ShellStrike::Host.new('192.168.1.100')
      ]

      @instance = ShellStrike.new(hosts, usernames, passwords)
      @instance.perform_attack
    """
    Then ShellStrike.identified_credentials should include the correct credentials

  Scenario: Identifying credentials when a host is unreachable
    Given There isn't an SSH server running on '192.168.1.100':22
    When I run the following code
    """
    usernames = ['root', 'admin']
      passwords = ['letmein', 'password']
      hosts = [
        ShellStrike::Host.new('192.168.1.101'),
        ShellStrike::Host.new('192.168.1.100')
      ]

      @instance = ShellStrike.new(hosts, usernames, passwords)
      @instance.perform_attack
    """
    Then ShellStrike.identified_credentials should be an empty hash
    And ShellStrike.unreachable_hosts should include the host with a message containing 'No route to host'

  Scenario: Identifying credentials when a host is online, but the valid credentials aren't present in the username and password dictionaries supplied
    Given There is an SSH server running on '172.20.16.20':22
    And the server has a valid username of 'admin' with a password of 'letmein'
    When I run the following code
    """
      usernames = ['root', 'administrator']
      passwords = ['letmein', 'password']
      hosts = [
        ShellStrike::Host.new('172.20.16.20')
      ]

      @instance = ShellStrike.new(hosts, usernames, passwords)
      @instance.perform_attack
    """
    Then ShellStrike.identified_credentials should be an empty hash
    And ShellStrike.failed_hosts should include the host
    And ShellStrike.unreachable_hosts should be an empty hash
