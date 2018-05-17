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

  describe '#on' do
    let(:instance) { ShellStrike.new([ShellStrike::Host.new('192.168.1.1')], ['root'], ['password']) }

    context 'with an invalid event' do
      it 'raises a ShellStrike::InvalidEvent error' do
        expect {
          instance.on(nil)
        }.to raise_error(ShellStrike::InvalidEvent)
      end
    end

    context 'with a valid event' do
      it 'subscribes to the event' do
        @x = 0
        instance.on(:my_new_event) do
          @x = 1
        end

        ShellStrike::Events.send(:emit, :my_new_event)

        expect(@x).to eq(1)
      end
    end
  end
end