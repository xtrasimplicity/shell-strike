require 'spec_helper'

describe ShellStrike::Host do
  include SSHHelper

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

  describe '#to_uri' do
    let(:host) { ShellStrike::Host.new('172.20.16.20', 200) }

    subject { host.to_uri }

    it { is_expected.to eq '172.20.16.20:200' }
  end

  describe '#valid_credentials?' do
    let(:host) { ShellStrike::Host.new('172.20.16.20', 200) }
    let(:username) { 'root' }
    let(:password) { 'password' }

    context 'when the credentials are valid' do
      before do
        stub_host_as_online(host.host, host.port)
        stub_valid_ssh_credentials(host.host, host.port, [ [username, password] ])
      end
      subject { host.valid_credentials?(username, password) }

      it { is_expected.to be(true) }
    end

    context 'when the credentials are invalid' do
      before do
        stub_host_as_online(host.host, host.port)
        stub_invalid_ssh_credentials(host.host, host.port, username, password)
      end
      subject { host.valid_credentials?(username, password) }

      it { is_expected.to be(false) }
    end
  end

  describe '#execute_actions' do
    context 'when the host was instantiated without any actions' do
      let(:host) { ShellStrike::Host.new('127.0.0.1', 22, 30, []) }

      context 'and no supplementary actions have been provided' do
        subject { host.execute_actions('fake_username', 'fake_password', []) }

        it 'returns an empty array' do
          expect(subject).to eq([])
        end
      end

      context 'and supplementary actions have been provided' do
        let(:username) { 'admin' }
        let(:password) { 'pa55w0rd' }
        let(:command) { 'whoami' }
        
        context 'and the credentials are invalid' do
          before do
            stub_host_as_online(host.host, host.port)
            stub_invalid_ssh_credentials(host.host, host.port, username, password)
          end

          subject { host.execute_actions(username, password, [command]) }

          it 'returns an array with the correct CommandResult object' do
            expect(subject).to be_a(Array)
            expect(subject).not_to be_empty

            actual_object = subject.first

            expect(actual_object.command).to eq(command)
            expect(actual_object.stdout).to eq('')
            expect(actual_object.stderr).to match(/credentials are invalid/i)
          end
        end
        end
      end
    end
  end
end