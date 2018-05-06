Feature: Identifying credentials for a single host
  Scenario: A host is online
    Given There is an SSH server running on '192.168.1.100':22
    And the server at '192.168.1.100':22 has the following valid credentials:
    | username | password |
    | admin    | letmein  |
    When I run the following code
    """
      usernames = ['root', 'admin']
      passwords = ['letmein', 'password']
      hosts = [
        ShellStrike::Host.new('192.168.1.100')
      ]

      @instance = ShellStrike.new(hosts, usernames, passwords)
      @instance.identify_credentials!
    """
    Then ShellStrike.identified_credentials['192.168.1.100:22'] should only include:
    | username | password |
    | admin    | letmein  |

  Scenario: A host is unreachable
    Given There isn't an SSH server running on '192.168.1.100':22
    When I run the following code
    """
    usernames = ['root', 'admin']
      passwords = ['letmein', 'password']
      hosts = [
        ShellStrike::Host.new('192.168.1.100')
      ]

      @instance = ShellStrike.new(hosts, usernames, passwords)
      @instance.identify_credentials!
    """
    Then ShellStrike.identified_credentials should be an empty hash
    And ShellStrike.unreachable_hosts should include '192.168.1.100':22 with an explanation of ':unreachable'

  Scenario: A connection to the host times out
    Given Connections to an SSH server running on '192.168.1.100':22 timeout
    When I run the following code
    """
    usernames = ['root', 'admin']
      passwords = ['letmein', 'password']
      hosts = [
        ShellStrike::Host.new('192.168.1.100')
      ]

      @instance = ShellStrike.new(hosts, usernames, passwords)
      @instance.identify_credentials!
    """
    Then ShellStrike.identified_credentials should be an empty hash
    And ShellStrike.unreachable_hosts should include '192.168.1.100':22 with an explanation of ':timeout'

  Scenario: A connection to the host fails unexpectedly
    Given Connections to an SSH server running on '192.168.1.100':22 fail with an unexpected error
    When I run the following code
    """
    usernames = ['root', 'admin']
      passwords = ['letmein', 'password']
      hosts = [
        ShellStrike::Host.new('192.168.1.100')
      ]

      @instance = ShellStrike.new(hosts, usernames, passwords)
      @instance.identify_credentials!
    """
    Then ShellStrike.identified_credentials should be an empty hash
    And ShellStrike.unreachable_hosts should include '192.168.1.100':22 with an explanation of ':unexpected_error'

  Scenario: A host is online, but the valid credentials aren't present in the username and password dictionaries
    Given There is an SSH server running on '172.20.16.20':22
    And the server at '172.20.16.20':22 has the following valid credentials:
    | username | password |
    | admin    | letmein  |
    When I run the following code
    """
      usernames = ['root', 'administrator']
      passwords = ['letmein', 'password']
      hosts = [
        ShellStrike::Host.new('172.20.16.20')
      ]

      @instance = ShellStrike.new(hosts, usernames, passwords)
      @instance.identify_credentials!
    """
    Then ShellStrike.identified_credentials should be an empty hash
    And ShellStrike.failed_hosts should include '172.20.16.20':22
    And ShellStrike.unreachable_hosts should be an empty hash

  Scenario: A host is online, and multiple valid credentials are present in the username and password dictionaries
    Given There is an SSH server running on '172.20.16.20':22
    And the server at '172.20.16.20':22 has the following valid credentials:
    | username | password |
    | admin    | letmein  |
    | root     | pa55w0rd |
    When I run the following code
    """
      usernames = ['root', 'admin', 'administrator']
      passwords = ['password', 'zxcvbnm', 'pa55w0rd', 'secr3t', 'letmein']
      hosts = [
        ShellStrike::Host.new('172.20.16.20')
      ]

      @instance = ShellStrike.new(hosts, usernames, passwords)
      @instance.identify_credentials!
    """
    Then ShellStrike.identified_credentials['172.20.16.20:22'] should only include:
    | username | password |
    | admin    | letmein  |
    | root     | pa55w0rd |