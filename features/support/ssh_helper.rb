require File.expand_path('../../../lib/tests/ssh_helper', __FILE__)

World(SSHHelper)

Before do
  allow(Net::SSH).to receive(:start).with(any_args)
end