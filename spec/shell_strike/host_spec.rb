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

  describe '#to_uri' do
    let(:host) { ShellStrike::Host.new('172.20.16.20', 200) }

    subject { host.to_uri }

    it { is_expected.to eq '172.20.16.20:200' }
  end
end