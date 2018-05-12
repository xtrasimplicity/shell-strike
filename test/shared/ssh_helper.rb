module SSHHelper
  def stub_host_as_online(host, port)
   allow(ShellStrike::Ssh).to receive(:check_host_reachable).with(an_object_having_attributes(host: host, port: port)).and_return([true, nil])
  end

  def stub_host_as_offline(host, port)
    allow(ShellStrike::Ssh).to receive(:check_host_reachable).with(an_object_having_attributes(host: host, port: port)).and_return([false, :unreachable])
  end

  def stub_all_hosts_as_offline
    allow(ShellStrike::Ssh).to receive(:check_host_reachable).with(any_args).and_return([false, :unreachable])
  end

  def stub_connection_timeout(host, port)
    allow(ShellStrike::Ssh).to receive(:check_host_reachable).with(an_object_having_attributes(host: host, port: port)).and_return([false, :timeout])
  end

  def stub_unexpected_connection_failure(host, port)
    allow(ShellStrike::Ssh).to receive(:check_host_reachable).with(an_object_having_attributes(host: host, port: port)).and_return([false, :unexpected_error])
  end

  def stub_valid_ssh_credentials(host, port, valid_credentials)
    allow(ShellStrike::Ssh).to receive(:valid_credentials?).with(an_object_having_attributes(host: host, port: port), anything, anything).and_return(false)

    
    valid_credentials.each do |username, password|
     allow(ShellStrike::Ssh).to receive(:valid_credentials?).with(an_object_having_attributes(host: host, port: port), username, password).and_return(true)
    end
  end

  def stub_invalid_ssh_credentials(host, port, username, password)
    allow(ShellStrike::Ssh).to receive(:valid_credentials?).with(an_object_having_attributes(host: host, port: port), username, password).and_return(false)
  end
end