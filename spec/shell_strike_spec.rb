require 'spec_helper'

RSpec.describe ShellStrike do
  include SSHHelper
  
  describe '#initialize' do
    let(:valid_hosts) { [ShellStrike::Host.new('192.168.1.100')] }
    let(:valid_usernames) { ['admin', 'root', 'administrator'] }
    let(:valid_passwords) { ['password', 'letmein'] }
    let(:valid_global_actions) { ['whoami'] }


    describe 'when the arguments are valid' do
      subject { ShellStrike.new(valid_hosts, valid_usernames, valid_passwords, valid_global_actions) }

      it 'stores the hosts' do
        expect(subject.hosts).to eq(valid_hosts)
      end

      it 'stores the usernames' do
        expect(subject.usernames).to eq(valid_usernames)
      end

      it 'stores the passwords' do
        expect(subject.passwords).to eq(valid_passwords)
      end

      it 'stores the global actions' do
        expect(subject.global_actions).to eq(valid_global_actions)
      end
    end

    describe 'when the arguments are invalid' do
      context 'hosts' do
        [nil, []].each do |val|
          val_as_string = val.nil? ? 'nil' : val.to_s

          context "when #{val_as_string}" do
            let(:hosts) { val }

            subject { Proc.new { ShellStrike.new(hosts, valid_usernames, valid_passwords, valid_global_actions) } }

            it { is_expected.to raise_error ShellStrike::HostsNotDefined }
          end
        end
      end

      context 'usernames' do
        [nil, []].each do |val|
          val_as_string = val.nil? ? 'nil' : val.to_s

          context "when #{val_as_string}" do
            let(:usernames) { val }

            subject { Proc.new { ShellStrike.new(valid_hosts, usernames, valid_passwords, valid_global_actions) } }

            it { is_expected.to raise_error ShellStrike::UsernamesNotDefined }
          end
        end
      end

      context 'passwords' do
        [nil, []].each do |val|
          val_as_string = val.nil? ? 'nil' : val.to_s

          context "when #{val_as_string}" do
            let(:passwords) { val }

            subject { Proc.new { ShellStrike.new(valid_hosts, valid_usernames, passwords, valid_global_actions) } }

            it { is_expected.to raise_error ShellStrike::PasswordsNotDefined }
          end
        end
      end
    end

    describe 'when global_actions are not defined' do
      subject { ShellStrike.new(valid_hosts, valid_usernames, valid_passwords) }

      it 'should default to []' do
        expect(subject.global_actions).to eq([])
      end
    end
  end

  describe '.execute_actions' do
    context 'when hosts with actions have been defined' do
      let(:username) { 'admin' }
      let(:password) { 'password' }
      let(:hosts) do
        [
          ShellStrike::Host.new('192.168.1.100', 22, 30, ['whoami']),
          ShellStrike::Host.new('192.168.1.101', 300, 30, ['whoami'])
        ]
      end
      let(:instance) { ShellStrike.new(hosts, [username], [password]) }

      before do
        hosts.each do |host|
          stub_valid_ssh_credentials(host.host, host.port, [username, password])
        end

        instance.identify_credentials!
      end
      subject { instance.execute_actions! }

      it 'returns a hash with the results' do
        expect(subject).to eq({
          '192.168.1.100:22': [
            {
              command: 'whoami',
              exit_code: 0,
              stdout: username,
              stderr: ''
            }
          ]
        })
      end
    end
  end

end