require 'spec_helper'

describe ShellStrike::Ssh do
  include SSHHelper

  describe '.host_listening?' do
    let(:host) { ShellStrike::Host.new('192.168.1.100', 22) }

    context 'when a host is listening' do
      before do
        allow(Net::SSH).to receive(:start).with(host.host, anything, hash_including(port: host.port)).and_return(true)
      end

      subject { ShellStrike::Ssh.host_listening?(host) }

      it { is_expected.to eq(true) }
    end

    context 'when a host is not listening' do
      before do
        allow(Net::SSH).to receive(:start).with(host.host, anything, hash_including(port: host.port)).and_raise(Errno::EHOSTUNREACH)
      end

      subject { ShellStrike::Ssh.host_listening?(host) }

      it { is_expected.to eq(false) }
    end

    context 'when a connection times out' do
      before do
        allow(Net::SSH).to receive(:start).with(host.host, anything, hash_including(port: host.port)).and_raise(Net::SSH::ConnectionTimeout)
      end

      subject { ShellStrike::Ssh.host_listening?(host) }

      it { is_expected.to eq(false) }
    end
  end


end