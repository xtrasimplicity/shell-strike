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
end