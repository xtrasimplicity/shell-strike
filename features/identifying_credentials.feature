Feature: ShellStrike
  Scenario: Identifying credentials when a host is online
    Given There is an SSH server running on '192.168.1.100':22
    And the server has a valid username of 'admin' with a password of 'letmein'
    When I set the usernames array to 'root,admin'
    And I set the passwords array to 'letmein,password'
    And I set the hosts array to include '192.168.1.100' on port 22
    And I run a ShellStrike attack
    Then ShellStrike.identified_credentials should include the correct credentials
