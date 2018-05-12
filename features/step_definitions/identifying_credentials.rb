Given("There is an SSH server running on {string}:{int}") do |hostname, port|
 stub_host_as_online(hostname, port)
end

Given("The following SSH servers are running and are accepting connections:") do |table|
  stub_all_hosts_as_offline

  table.rows.each do |host, port|
    step %(There is an SSH server running on "#{host}":#{port})
  end
end

Given("There isn't an SSH server running on {string}:{int}") do |hostname, port|
  stub_host_as_offline(hostname, port)
end


Given("Connections to an SSH server running on {string}:{int} timeout") do |hostname, port|
  stub_connection_timeout(hostname, port)
end

Given("Connections to an SSH server running on {string}:{int} fail with an unexpected error") do |hostname, port|
  stub_unexpected_connection_failure(hostname, port)
end

Given("the server at {string}:{int} has the following valid credentials:") do |host, port, table|
  @valid_credentials = table.rows

  stub_valid_ssh_credentials(host, port, @valid_credentials)
end
When("I run the following code") do |code|
  eval code
end

Then("ShellStrike.identified_credentials[{string}] should only include:") do |host_uri, expected_credentials_table|
  identified_credentials_by_host = @instance.identified_credentials

  expect(identified_credentials_by_host).to have_key host_uri
  
  actual_credentials = identified_credentials_by_host[host_uri]
  expected_credentials = expected_credentials_table.rows

  expect(actual_credentials.length).to eq expected_credentials.length

  expected_credentials.each do |credentials|
    expect(actual_credentials).to include credentials
  end
end


Then("ShellStrike.identified_credentials should be an empty hash") do
  expect(@instance.identified_credentials).to eq({})
end

Then("ShellStrike.identified_credentials[{string}] should not exist") do |host_uri|
  subject = @instance.identified_credentials

  expect(subject).not_to have_key(host_uri)
end

Then("ShellStrike.unreachable_hosts should include {string}:{int} with an explanation of {string}") do |host, port, explanation|
  unreachable_hosts = @instance.unreachable_hosts

  expect(unreachable_hosts).to include("#{host}:#{port}" => explanation.gsub(':', '').to_sym)
end

Then("ShellStrike.unreachable_hosts should be an empty hash") do
  expect(@instance.unreachable_hosts).to eq({})
end

Then("ShellStrike.failed_hosts should include {string}:{int}") do |host, port|
  failed_hosts_as_array_of_hashes = @instance.failed_hosts.collect { |host| host_as_hash(host) }
  subject_host_as_hash = host_as_hash(ShellStrike::Host.new(host, port))
  
  expect(failed_hosts_as_array_of_hashes).to include(subject_host_as_hash)
end