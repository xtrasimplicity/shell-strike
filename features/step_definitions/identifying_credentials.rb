Given("There is an SSH server running on {string}:{int}") do |hostname, port|
  @actual_server = ShellStrike::Host.new(hostname, port)
  
  # Raise an authentication failed exception for ALL authentication attempts
  allow(Net::SSH).to receive(:start).and_raise Net::SSH::AuthenticationFailed

  # Pass authentication when this username, password and host combination is supplied
  allow(Net::SSH).to receive(:start).with(hostname, anything, hash_including(port: port)).and_return(true)
end

Given("There isn't an SSH server running on {string}:{int}") do |hostname, port|
  @actual_server = ShellStrike::Host.new(hostname, port)

  # Raise an authentication failed exception for ALL authentication attempts
  allow(Net::SSH).to receive(:start).and_raise Net::SSH::AuthenticationFailed

  # Raise Host Unreachable error for connection attempts to this host and port combination
  allow(Net::SSH).to receive(:start).with(hostname, anything, hash_including(port: port)).and_raise(Errno::EHOSTUNREACH)
end

Given("the server has a valid username of {string} with a password of {string}") do |username, password|
  # Raise an authentication failed exception for ALL authentication attempts
  allow(Net::SSH).to receive(:start).and_raise Net::SSH::AuthenticationFailed

  # Pass authentication when this username, password and host combination is supplied
  allow(Net::SSH).to receive(:start).with(@actual_server.host, username, hash_including(port: @actual_server.port, password: password)).and_return(true)

  @actual_username = username
  @actual_password = password
end

When("I run the following code") do |code|
  eval code
end

Then("ShellStrike.identified_credentials should include the correct credentials") do
  identified_credentials = @instance.identified_credentials

  expect(identified_credentials).to include(@actual_server.to_uri => [@actual_username, @actual_password])
end

Then("ShellStrike.identified_credentials should be an empty hash") do
  expect(@instance.identified_credentials).to eq({})
end

Then("ShellStrike.unreachable_hosts should include the host with a message containing {string}") do |message|
  unreachable_hosts = @instance.unreachable_hosts

  expect(unreachable_hosts).to include(@actual_server.to_uri => Regexp.new(message))
end