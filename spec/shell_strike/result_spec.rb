require 'spec_helper'

describe ShellStrike::Result do
  describe '#success?' do
    context 'when initialised with `false`' do
      let(:instance) { ShellStrike::Result.new(false, '') }
      subject { instance.success? }

      it { is_expected.to be false }
    end

    context 'when initialised with `true`' do
      let(:instance) { ShellStrike::Result.new(true, '') }
      subject { instance.success? }

      it { is_expected.to be true }
    end
  end

  describe '#message' do
    let(:message) { 'This is a test message!' }
    let(:instance) { ShellStrike::Result.new(true, message) }
    subject { instance.message }

    it { is_expected.to eq message }
  end

  describe '#error_type' do
    context 'when #success? is true' do
      let(:instance) { ShellStrike::Result.new(true, '') }
      subject { instance.error_type }

      it { is_expected.to be nil }
    end

    supported_error_types = [:authentication_failure, :connection_timeout, :host_unreachable]

    supported_error_types.each do |error_type|
      context "when initialised with `:#{error_type}`" do
        let(:instance) { ShellStrike::Result.new(false, 'Failure message', error_type) }
        subject { instance.error_type }

        it { is_expected.to eq error_type }
      end
    end
  end
end