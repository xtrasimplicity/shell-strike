Given("There is an SSH server running on {string}:{int}") do |hostname, port|
  @actual_server = ShellStrike::Host.new(hostname, port)
  
  mock_host_as_online(hostname, port)
end

Given("There isn't an SSH server running on {string}:{int}") do |hostname, port|
  @actual_server = ShellStrike::Host.new(hostname, port)

  mock_host_as_offline(hostname, port)
end


Given("Connections to an SSH server running on {string}:{int} timeout") do |hostname, port|
  @actual_server = ShellStrike::Host.new(hostname, port)

  mock_connection_timeout(hostname, port)
end

Given("Connections to an SSH server running on {string}:{int} fail with an unexpected error") do |hostname, port|
  @actual_server = ShellStrike::Host.new(hostname, port)

  mock_unexpected_connection_failure(hostname, port)
end

Given("the server has the following valid credentials:") do |table|
  @valid_credentials = table.rows

  stub_valid_ssh_credentials(@actual_server.host, @actual_server.port, @valid_credentials)
end

When("I run the following code") do |code|
  eval code
end

Then("ShellStrike.identified_credentials should only include:") do |expected_credentials_table|
  identified_credentials_by_host = @instance.identified_credentials

  expect(identified_credentials_by_host).to have_key @actual_server.to_uri
  
  actual_credentials = identified_credentials_by_host[@actual_server.to_uri]
  expected_credentials = expected_credentials_table.rows

  expect(actual_credentials.length).to eq expected_credentials.length

  expected_credentials.each do |credentials|
    expect(actual_credentials).to include credentials
  end
end


Then("ShellStrike.identified_credentials should be an empty hash") do
  expect(@instance.identified_credentials).to eq({})
end

Then("ShellStrike.unreachable_hosts should include the host with a message containing {string}") do |message|
  unreachable_hosts = @instance.unreachable_hosts

  expect(unreachable_hosts).to include(@actual_server.to_uri => Regexp.new(message))
end

Then("ShellStrike.unreachable_hosts should be an empty hash") do
  expect(@instance.unreachable_hosts).to eq({})
end

Then("ShellStrike.failed_hosts should include the host") do
  failed_hosts_as_array_of_hashes = @instance.failed_hosts.collect { |host| host_as_hash(host) }
  subject_host_as_hash = host_as_hash(@actual_server)
  
  expect(failed_hosts_as_array_of_hashes).to include(subject_host_as_hash)
end