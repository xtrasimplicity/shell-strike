require 'spec_helper'

RSpec.describe ShellStrike do
  describe '#initialize' do
    let(:hosts) do
      [
        {
          address: '192.168.1.100',
          port: 22,
          actions: []
        }
      ]
    end
    let(:usernames) { ['admin', 'root', 'administrator'] }
    let(:passwords) { ['password', 'letmein'] }
    let(:global_actions) { ['whoami'] }
    
    subject { ShellStrike.new(hosts, usernames, passwords, global_actions) }

    it 'stores the hosts' do
      expect(subject.hosts).to eq(hosts)
    end

    it 'stores the usernames' do
      expect(subject.usernames).to eq(usernames)
    end

    it 'stores the passwords' do
      expect(subject.passwords).to eq(passwords)
    end

    it 'stores the global actions' do
      expect(subject.global_actions).to eq(global_actions)
    end
  end
end