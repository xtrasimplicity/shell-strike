module SSHHelper
  def mock_host_as_online(host, port)
    allow(Net::SSH).to receive(:start).with(host, anything, hash_including(port: port)).and_return(true)
  end

  def mock_host_as_offline(host, port)
    allow(Net::SSH).to receive(:start).with(host, anything, hash_including(port: port)).and_raise Errno::EHOSTUNREACH
  end

  def mock_all_hosts_as_offline
    allow(Net::SSH).to receive(:start).with(any_args).and_raise Errno::EHOSTUNREACH
  end

  def mock_connection_timeout(host, port)
    allow(Net::SSH).to receive(:start).with(host, anything, hash_including(port: port)).and_raise Net::SSH::ConnectionTimeout
  end

  def mock_unexpected_connection_failure(host, port)
    allow(Net::SSH).to receive(:start).with(host, anything, hash_including(port: port)).and_raise Net::SSH::Exception
  end

  def stub_valid_ssh_credentials(host, port, valid_credentials)
    allow(Net::SSH).to receive(:start).with(host, anything, hash_including(port: port)).and_raise Net::SSH::AuthenticationFailed

    valid_credentials.each do |username, password|
      allow(Net::SSH).to receive(:start).with(host, username, hash_including(port: port, password: password)).and_return true
    end
  end
end
World(SSHHelper)

Before do
  allow(Net::SSH).to receive(:start).with(any_args)
end