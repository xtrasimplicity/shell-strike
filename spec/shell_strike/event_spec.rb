require 'spec_helper'

describe ShellStrike::Events do
  describe '.on' do
    describe 'with an invalid event' do
      it 'raises a ShellStrike::InvalidEvent error' do
        expect {
          ShellStrike::Events.on(nil)
        }.to raise_error(ShellStrike::InvalidEvent)
      end
    end

    it 'subscribes to the event' do
      @x = 0
      ShellStrike::Events.on(:my_new_event) do
        @x = 1
      end

      ShellStrike::Events.emit(:my_new_event)

      expect(@x).to eq(1)
    end
  end

  describe '.emit' do
    describe 'with an invalid event' do
      it 'raises a ShellStrike::InvalidEvent error' do
        expect {
          ShellStrike::Events.emit(nil)
        }.to raise_error(ShellStrike::InvalidEvent)
      end
    end
  end
end