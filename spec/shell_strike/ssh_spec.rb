require 'spec_helper'

module SshMockHelper
  def mock_valid_credentials(host_obj, username, password)
   allow(ShellStrike::Ssh).to receive(:valid_credentials?).with(host_obj, username, password).and_return(true)
  end

  def mock_invalid_credentials(host_obj, username, password)
    allow(ShellStrike::Ssh).to receive(:valid_credentials?).with(host_obj, username, password).and_return(false)
  end
end

describe ShellStrike::Ssh do
  include SshMockHelper

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

  describe '.valid_credentials?' do
    let(:host) { ShellStrike::Host.new('192.168.1.100', 22) }

    context 'when a host is not reachable' do
      before do
        allow(ShellStrike::Ssh).to receive(:host_listening?).with(host).and_return(false)
      end

      subject { ShellStrike::Ssh.valid_credentials?(host, 'admin', 'password') }

      it { is_expected.to eq(false) }
    end

    context 'when a host is reachable' do
      before do
        allow(ShellStrike::Ssh).to receive(:host_listening?).with(host).and_return(true)
      end

      context 'when the credentials are valid' do
        let(:username) { 'admin' }
        let(:password) { 'password' }

        before do
          allow(Net::SSH).to receive(:start).with(host.host, username, hash_including(port: host.port, password: password)).and_return(true)
        end

        subject { ShellStrike::Ssh.valid_credentials?(host, username, password) }

        it { is_expected.to eq(true) }
      end

      context 'when the credentials are invalid' do
        let(:username) { 'admin' }
        let(:password) { 'password' }

        before do
          allow(Net::SSH).to receive(:start).with(host.host, username, hash_including(port: host.port, password: password)).and_raise(Net::SSH::AuthenticationFailed)
        end

        subject { ShellStrike::Ssh.valid_credentials?(host, username, password) }

        it { is_expected.to eq(false) }
      end
    end
  end

  describe '.execute_command' do
    let(:host) { ShellStrike::Host.new('192.168.1.100', 22) }
    let(:username) { 'root' }
    let(:password) { 'password' }
    let(:command) { 'whoami' }
    
    context 'when a host is not reachable' do
      before do
        allow(ShellStrike::Ssh).to receive(:host_listening?).with(host).and_return(false)
      end

      it 'raises ShellStrike::Ssh::HostUnreachableError' do
        expect { ShellStrike::Ssh.execute_command(host, username, password, command) }.to raise_error ShellStrike::Ssh::HostUnreachableError
      end
    end

    context 'when a host is reachable' do
      before do
        allow(ShellStrike::Ssh).to receive(:host_listening?).with(host).and_return(true)
      end

      context 'when the credentials are invalid' do
        before { mock_invalid_credentials(host, username, password) }

        it 'raises ShellStrike::Ssh::InvalidCredentialsError' do
          expect { ShellStrike::Ssh.execute_command(host, username, password, command) }.to raise_error ShellStrike::Ssh::InvalidCredentialsError
        end
      end

      context 'when the credentials are valid' do
        it { skip }
      end
    end

  end

end