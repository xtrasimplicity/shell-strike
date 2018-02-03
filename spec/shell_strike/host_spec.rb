require 'spec_helper'

describe ShellStrike::Host do
  describe '#initialize' do
    let(:host_address) { '192.168.1.1' }
    let(:port) { '2222' }
    let(:connection_timeout) { 30 }
    let(:actions) { ['whoami', 'ls /'] }
    subject { ShellStrike::Host.new(host_address, port, connection_timeout, actions) }

    it 'sets the `host` attribute' do
      expect(subject.host).to eq(host_address)
    end

    it 'sets the `port` attribute' do
      expect(subject.port).to eq(port)
    end

    it 'sets the `connection_timeout` attribute' do
      expect(subject.connection_timeout).to eq(connection_timeout)
    end

    it 'sets the `actions` attribute' do
      expect(subject.actions).to eq(actions)
    end

    context 'when a port is not defined' do
      subject { ShellStrike::Host.new(host_address) }

      it 'sets the `port` attribute to `22`' do
        expect(subject.port).to eq(22)
      end
    end

    context 'when a `connection timeout` is not defined' do
      subject { ShellStrike::Host.new(host_address) }

      it 'sets the `connection timeout` attribute to `30` seconds' do
        expect(subject.connection_timeout).to eq(30)
      end
    end

    context 'when `actions` is not defined' do
      subject { ShellStrike::Host.new(host_address) }

      it 'sets the `actions` attribute to []' do
        expect(subject.actions).to eq([])
      end
    end
  end

  describe '#reachable?' do
    let(:host) { ShellStrike::Host.new('192.168.1.1') }
    subject { host.reachable? }

    context 'when the host is unreachable' do
      before { allow(Socket).to receive(:tcp).and_raise(Errno::EHOSTUNREACH) }
      
      it { is_expected.to eq(false) }
    end

    context 'when the connection times out' do
      before { allow(Socket).to receive(:tcp).and_raise(Errno::ETIMEDOUT) }
    
      it { is_expected.to eq(false) }
    end

    context 'when the connection is successful' do
      before { allow(Socket).to receive(:tcp).and_return(true) }
    
      it { is_expected.to eq(true) }
    end
  end

  describe '#test_credentials' do
    let(:host) { ShellStrike::Host.new('192.168.1.1') }
    let(:username) { 'admin' }
    let(:password) { 'thisIsAFakePassword' }

    context 'when the credentials are valid' do
      before { allow(Net::SSH).to receive(:start).and_return(true) }
      subject { host.test_credentials(username, password) }

      it { is_expected.to return_a_result_object.with_a_success_value_of(true).and_no_message }
    end

    context 'when the credentials are invalid' do
      before { allow(Net::SSH).to receive(:start).and_raise(Net::SSH::AuthenticationFailed) }
      subject { host.test_credentials(username, password) }

      it { is_expected.to return_a_result_object.with_a_success_value_of(false).and_a_message_matching(/invalid credentials/i) }
    end

    context 'when the host is unreachable' do
      before { allow(Net::SSH).to receive(:start).and_raise(Errno::EHOSTUNREACH) }
      subject { host.test_credentials(username, password) }

      it { is_expected.to return_a_result_object.with_a_success_value_of(false).and_a_message_matching(/no route to host/i) }
    end

    context 'when the connection times out' do
      before { allow(Net::SSH).to receive(:start).and_raise(Net::SSH::ConnectionTimeout) }
      subject { host.test_credentials(username, password) }

      it { is_expected.to return_a_result_object.with_a_success_value_of(false).and_a_message_matching(/timed out/i) }
    end

    context 'when an unexpected SSH error occurs' do
      before { allow(Net::SSH).to receive(:start).and_raise(Net::SSH::Exception) }
      subject { host.test_credentials(username, password) }

      it { is_expected.to return_a_result_object.with_a_success_value_of(false).and_a_message_matching(/unexpected error occurred/i) }
    end
  end
end