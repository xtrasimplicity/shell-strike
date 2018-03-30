module SSHHelper
  def mock_host_as_online(host, port)
    force_ssh_authentication_failure_for_all_credentials

    allow(Net::SSH).to receive(:start).with(host, anything, hash_including(port: port)).and_return(true)
  end

  def mock_host_as_offline(host, port)
    force_ssh_authentication_failure_for_all_credentials

    allow(Net::SSH).to receive(:start).with(host, anything, hash_including(port: port)).and_raise Errno::EHOSTUNREACH
  end

  def mock_connection_timeout(host, port)
    force_ssh_authentication_failure_for_all_credentials

    allow(Net::SSH).to receive(:start).with(host, anything, hash_including(port: port)).and_raise Net::SSH::ConnectionTimeout
  end

  def mock_unexpected_connection_failure(host, port)
    force_ssh_authentication_failure_for_all_credentials

    allow(Net::SSH).to receive(:start).with(host, anything, hash_including(port: port)).and_raise Net::SSH::Exception
  end

  def stub_valid_ssh_credentials(host, port,valid_credentials)
    force_ssh_authentication_failure_for_all_credentials

    valid_credentials.each do |username, password|
      allow(Net::SSH).to receive(:start).with(host, username, hash_including(port: port, password: password)).and_return true
    end
  end

  private

  def force_ssh_authentication_failure_for_all_credentials
    allow(Net::SSH).to receive(:start).with(no_args).and_raise Net::SSH::AuthenticationFailed
    allow(Net::SSH).to receive(:start).with(any_args).and_raise Net::SSH::AuthenticationFailed
  end
end
World(SSHHelper)