require 'spec_helper'

describe ShellStrike::EventBus do
  let(:instance) { ShellStrike::EventBus.new }

  describe '.on' do
    describe 'with an invalid event' do
      it 'raises a ShellStrike::InvalidEvent error' do
        expect {
          instance.on(nil)
        }.to raise_error(ShellStrike::InvalidEvent)
      end
    end

    it 'subscribes to the event' do
      @x = 0
      instance.on(:my_new_event) do
        @x = 1
      end

      instance.emit(:my_new_event)

      expect(@x).to eq(1)
    end
  end

  describe '.emit' do
    describe 'with an invalid event' do
      it 'raises a ShellStrike::InvalidEvent error' do
        expect {
          instance.emit(nil)
        }.to raise_error(ShellStrike::InvalidEvent)
      end
    end

    it 'it does not raise an error if noone is listening' do
      expect { 
        instance.emit(:my_event)
      }.not_to raise_error
    end
  end
end