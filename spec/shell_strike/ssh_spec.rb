require 'spec_helper'

module SshMockHelper
  def mock_valid_credentials(host_obj, username, password)
   allow(ShellStrike::Ssh).to receive(:valid_credentials?).with(host_obj, username, password).and_return(true)
  end

  def mock_invalid_credentials(host_obj, username, password)
    allow(ShellStrike::Ssh).to receive(:valid_credentials?).with(host_obj, username, password).and_return(false)
  end

  def mock_ssh_session(host_obj, username, password, **double_options)
    mock_valid_credentials(host_obj, username, password)

    session = instance_double('Net::SSH::Connection::Session', double_options)

    allow(Net::SSH).to receive(:start).with(host_obj.host, username, hash_including(port: host_obj.port, password: password)).and_yield(session)

    session
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

      context 'when a Net::SSH::AuthenticationFailed error is raised' do
        before do
          allow(Net::SSH).to receive(:start).with(host.host, anything, hash_including(port: host.port)).and_raise(Net::SSH::AuthenticationFailed)
        end

        subject { ShellStrike::Ssh.host_listening?(host) }

        it { is_expected.to eq(true) }
      end
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
        let(:ssh_session) { mock_ssh_session(host, username, password) }
        let(:ssh_channel) { instance_double('Net::SSH::Connection::Channel') }
        let(:buffer) { instance_double('Net::SSH::Buffer') }

        before do
          allow(ssh_session).to receive(:open_channel).and_yield(ssh_channel)
        end

        context 'when the shell couldn\'t execute the command' do
          before do
            allow(ssh_channel).to receive(:exec).and_yield(ssh_channel, false)
          end

          it 'raises ShellStrike::Ssh::CommandExecutionFailureError' do
            expect { ShellStrike::Ssh.execute_command(host, username, password, command) }.to raise_error ShellStrike::Ssh::CommandExecutionFailureError
          end
        end

        context 'when the shell successfully executed the command' do
          let(:expected_exit_code) { 0 }
          let(:expected_stdout_content) { ['First line of the command\'s output.','Each additional line is a new item in the array.'] }
          let(:expected_stderr_content) { ['Error: Unable to do complete the task.', 'Please check the arguments you supplied and try again.']}
          before do
            expect(ssh_channel).to receive(:exec).and_yield(ssh_channel, true)
            expect(ssh_channel).to receive(:wait)
            allow(ssh_channel).to receive(:on_request).with(any_args)
            allow(ssh_channel).to receive(:on_data).with(no_args)
            allow(ssh_channel).to receive(:on_extended_data).with(no_args)
          end

          subject { ShellStrike::Ssh.execute_command(host, username, password, command) }

          it 'returns a CommandResult object' do
            expect(subject).to be_a_kind_of(ShellStrike::Ssh::CommandResult)
          end

          it 'stores the command' do
            expect(subject.command).to eq(command)
          end

          it 'stores the exit_code' do
            expect(ssh_channel).to receive(:on_request).with('exit-status').and_yield(ssh_channel, buffer)
            expect(buffer).to receive(:read_long).and_return(expected_exit_code)

            expect(subject.exit_code).to eq(expected_exit_code)
          end

          it 'stores the stdout content as an array' do
            buffer_content = expected_stdout_content.join("\n")
            
            expect(ssh_channel).to receive(:on_data).and_yield(ssh_channel, buffer)
            expect(buffer).to receive(:read).and_return(buffer_content)

            expect(subject.stdout).to eq(expected_stdout_content)
          end

          it 'sets the stderr content as an array' do
            buffer_content = expected_stderr_content.join("\n")

            expect(ssh_channel).to receive(:on_extended_data).and_yield(ssh_channel, buffer)
            expect(buffer).to receive(:read).and_return(buffer_content)

            expect(subject.stderr).to eq(expected_stderr_content)
          end
        end
      end
    end

  end

end