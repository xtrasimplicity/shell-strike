require 'spec_helper'

describe ShellStrike::Result do
  describe '#initialize' do
    let(:exception) { ArgumentError.new('This is an example exception') }

    context 'when an exception is not supplied' do
      subject { ShellStrike::Result.new(true, '') }

      it 'sets the `exception` attribute to nil' do
        expect(subject.exception).to eq(nil)
      end
    end

    context 'when an exception is supplied' do
      subject { ShellStrike::Result.new(true, '', exception) }

      it 'sets the `exception` attribute' do
        expect(subject.exception).to eq(exception)
      end
    end
  end

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