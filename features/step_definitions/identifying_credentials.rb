Given("There is an SSH server running on {string}:{int}") do |hostname, port|
  @actual_server = ShellStrike::Host.new(hostname, port)
end

Given("the server has a valid username of {string} with a password of {string}") do |username, password|
  allow(Net::SSH).to receive(:start).and_return(false)
  allow(Net::SSH).to receive(:start).with(@actual_server.host, username, port: @actual_server.port, password: password).and_return(true)

  @actual_username = username
  @actual_password = password
end

When("I set the usernames array to {string}") do |usernames_string|
  @usernames = usernames_string.split(',')
end

When("I set the passwords array to {string}") do |passwords_string|
  @passwords = passwords_string.split(',')
end

When("I set the hosts array to include {string} on port {int}") do |hostname, port|
  @hosts = [ShellStrike::Host.new(hostname, port)]
end

When("I run a ShellStrike attack") do
  @instance = ShellStrike.new(@hosts, @usernames, @passwords)

  @instance.perform_attack
end

Then("ShellStrike.identified_credentials should include the correct credentials") do
  @instance.identified_credentials[@actual_server.to_uri] == [@actual_username, @actual_password]
end