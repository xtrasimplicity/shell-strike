Feature: Identifying credentials for multiple hosts at once
  Scenario: All hosts are online, and valid credentials exist for each host
    Given The following SSH servers are running and are accepting connections:
    | host          | port  |
    | 192.168.1.100 | 22    |
    | somehost.com  | 300    |
    And the server at '192.168.1.100':22 has the following valid credentials:
    | username | password |
    | admin    | pa55w0rd |
    And the server at 'somehost.com':300 has the following valid credentials:
    | username | password |
    | root    | my_secret |
    When I run the following code
    """
      usernames = ['root', 'admin']
      passwords = ['my_secret', 'pa55w0rd']
      hosts = [
        ShellStrike::Host.new('192.168.1.100'),
        ShellStrike::Host.new('somehost.com', 300)
      ]

      @instance = ShellStrike.new(hosts, usernames, passwords)
      @instance.identify_credentials!
    """
    Then ShellStrike.identified_credentials['192.168.1.100:22'] should only include:
    | username  | password  |
    | admin     | pa55w0rd  |
    And ShellStrike.identified_credentials['somehost.com:300'] should only include:
    | username  | password  |
    | root      | my_secret |
  
  Scenario: All hosts are online, and valid credentials can only be found for one host
    Given The following SSH servers are running and are accepting connections:
    | host          | port  |
    | 192.168.1.100 | 22    |
    | somehost.com  | 300    |
    And the server at '192.168.1.100':22 has the following valid credentials:
    | username | password |
    | bob    | letmein |
    And the server at 'somehost.com':300 has the following valid credentials:
    | username | password |
    | root    | my_secret |
    When I run the following code
    """
      usernames = ['root', 'admin']
      passwords = ['my_secret', 'pa55w0rd']
      hosts = [
        ShellStrike::Host.new('192.168.1.100'),
        ShellStrike::Host.new('somehost.com', 300)
      ]

      @instance = ShellStrike.new(hosts, usernames, passwords)
      @instance.identify_credentials!
    """
    And ShellStrike.identified_credentials['192.168.1.100:22'] should not exist
    And ShellStrike.identified_credentials['somehost.com:300'] should only include:
    | username  | password  |
    | root      | my_secret |

  Scenario: All hosts are online, and multiple valid credentials can be found for one host
    Given The following SSH servers are running and are accepting connections:
    | host          | port  |
    | 192.168.1.100 | 22    |
    | somehost.com  | 300    |
    And the server at '192.168.1.100':22 has the following valid credentials:
    | username | password |
    | bob    | letmein |
    And the server at 'somehost.com':300 has the following valid credentials:
    | username | password |
    | root    | my_secret |
    | admin   | s5cr3t    |
    When I run the following code
    """
      usernames = ['root', 'admin']
      passwords = ['my_secret', 'pa55w0rd', 's5cr3t']
      hosts = [
        ShellStrike::Host.new('192.168.1.100'),
        ShellStrike::Host.new('somehost.com', 300)
      ]

      @instance = ShellStrike.new(hosts, usernames, passwords)
      @instance.identify_credentials!
    """
    And ShellStrike.identified_credentials['192.168.1.100:22'] should not exist
    And ShellStrike.identified_credentials['somehost.com:300'] should only include:
    | username  | password  |
    | root      | my_secret |
    | admin     | s5cr3t    |

  Scenario: A single host is unreachable, the other is reachable and has valid credentials
    Given There is an SSH server running on '192.168.1.101':22
    And There isn't an SSH server running on '192.168.1.100':22
    And the server at '192.168.1.101':22 has the following valid credentials:
    | username  | password  |
    | root      | password  |
    When I run the following code
    """
    usernames = ['root', 'admin']
      passwords = ['letmein', 'password']
      hosts = [
        ShellStrike::Host.new('192.168.1.101'),
        ShellStrike::Host.new('192.168.1.100')
      ]

      @instance = ShellStrike.new(hosts, usernames, passwords)
      @instance.identify_credentials!
    """
    Then ShellStrike.identified_credentials['192.168.1.101:22'] should only include:
    | username  | password  |
    | root      | password  |
    And ShellStrike.identified_credentials['192.168.1.100:22'] should not exist
    And ShellStrike.unreachable_hosts should include '192.168.1.100':22 with an explanation of ':unreachable'

  Scenario: A single host is unreachable, the other is reachable and has invalid credentials
    Given There is an SSH server running on '192.168.1.101':22
    And There isn't an SSH server running on '192.168.1.100':22
    And the server at '192.168.1.101':22 has the following valid credentials:
    | username  | password  |
    | root      | pa55w0rd  |
    When I run the following code
    """
    usernames = ['root', 'admin']
      passwords = ['letmein', 'password']
      hosts = [
        ShellStrike::Host.new('192.168.1.101'),
        ShellStrike::Host.new('192.168.1.100')
      ]

      @instance = ShellStrike.new(hosts, usernames, passwords)
      @instance.identify_credentials!
    """
    Then ShellStrike.identified_credentials['192.168.1.101:22'] should not exist
    And ShellStrike.identified_credentials['192.168.1.100:22'] should not exist
    And ShellStrike.unreachable_hosts should include '192.168.1.100':22 with an explanation of ':unreachable'

  Scenario: Both hosts are unreachable
    Given There isn't an SSH server running on '192.168.1.101':22
    And There isn't an SSH server running on '192.168.1.100':22
    When I run the following code
    """
    usernames = ['root', 'admin']
      passwords = ['letmein', 'password']
      hosts = [
        ShellStrike::Host.new('192.168.1.101'),
        ShellStrike::Host.new('192.168.1.100')
      ]

      @instance = ShellStrike.new(hosts, usernames, passwords)
      @instance.identify_credentials!
    """
    Then ShellStrike.identified_credentials['192.168.1.101:22'] should not exist
    And ShellStrike.identified_credentials['192.168.1.100:22'] should not exist
    And ShellStrike.unreachable_hosts should include '192.168.1.101':22 with an explanation of ':unreachable'
    And ShellStrike.unreachable_hosts should include '192.168.1.100':22 with an explanation of ':unreachable'


  Scenario: Connections to all hosts time out
    Given Connections to an SSH server running on '192.168.1.100':22 timeout
    Given Connections to an SSH server running on '192.168.1.101':22 timeout
    Given Connections to an SSH server running on '192.168.1.102':22 timeout
    When I run the following code
    """
    usernames = ['root', 'admin']
      passwords = ['letmein', 'password']
      hosts = [
        ShellStrike::Host.new('192.168.1.100'),
        ShellStrike::Host.new('192.168.1.101'),
        ShellStrike::Host.new('192.168.1.102')
      ]

      @instance = ShellStrike.new(hosts, usernames, passwords)
      @instance.identify_credentials!
    """
    Then ShellStrike.identified_credentials should be an empty hash
    And ShellStrike.unreachable_hosts should include '192.168.1.100':22 with an explanation of ':timeout'
    And ShellStrike.unreachable_hosts should include '192.168.1.101':22 with an explanation of ':timeout'
    And ShellStrike.unreachable_hosts should include '192.168.1.102':22 with an explanation of ':timeout'

    Scenario: Connections to one host times out, the others have valid credentials
    Given The following SSH servers are running and are accepting connections:
    | Host          | port  |
    | 192.168.1.101 | 22    |
    | 192.168.1.102 | 22    |
    And Connections to an SSH server running on '192.168.1.100':22 timeout
    And the server at '192.168.1.101':22 has the following valid credentials:
    | username  | password  |
    | root      | password  |
    And the server at '192.168.1.102':22 has the following valid credentials:
    | username  | password  |
    | bob       | drowpass  |
    When I run the following code
    """
    usernames = ['root', 'admin', 'bob']
      passwords = ['letmein', 'password', 'drowpass']
      hosts = [
        ShellStrike::Host.new('192.168.1.100'),
        ShellStrike::Host.new('192.168.1.101'),
        ShellStrike::Host.new('192.168.1.102')
      ]

      @instance = ShellStrike.new(hosts, usernames, passwords)
      @instance.identify_credentials!
    """
    Then ShellStrike.identified_credentials['192.168.1.101:22'] should only include:
    | username  | password  |
    | root      | password  |
    And ShellStrike.identified_credentials['192.168.1.102:22'] should only include:
    | username  | password  |
    | bob       | drowpass  |
    And ShellStrike.unreachable_hosts should include '192.168.1.100':22 with an explanation of ':timeout'

  Scenario: A connection to one host fails unexpectedly, the other hosts are OK but no credentials could be identified
    Given The following SSH servers are running and are accepting connections:
    | Host          | port  |
    | 192.168.1.101 | 300    |
    | 192.168.1.102 | 22    |
    And Connections to an SSH server running on '192.168.1.103':22 fail with an unexpected error
    And the server at '192.168.1.101':300 has the following valid credentials:
    | username  | password  |
    | bob       | drowpass  |
    And the server at '192.168.1.102':22 has the following valid credentials:
    | username      | password  |
    | administrator | s5cr3t    |
    When I run the following code
    """
    usernames = ['root', 'admin']
      passwords = ['letmein', 'password']
      hosts = [
        ShellStrike::Host.new('192.168.1.101', 300),
        ShellStrike::Host.new('192.168.1.102'),
        ShellStrike::Host.new('192.168.1.103')
      ]

      @instance = ShellStrike.new(hosts, usernames, passwords)
      @instance.identify_credentials!
    """
    Then ShellStrike.identified_credentials should be an empty hash
    And ShellStrike.unreachable_hosts should include '192.168.1.103':22 with an explanation of ':unexpected_error'