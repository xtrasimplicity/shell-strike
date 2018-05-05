require 'spec_helper'

describe ShellStrike::Ssh::CommandResult do
  describe '#initialize' do
    let(:command) { 'some_task' }
    let(:exit_code) { 1 }
    let(:stdout) { 'An error occurred!' }
    let(:stderr) { 'Unable to do X'}

    subject { ShellStrike::Ssh::CommandResult.new(command: command, exit_code: exit_code, stdout: stdout, stderr: stderr) }

    it 'stores the required attributes' do
      expect(subject.command).to eq(command)
      expect(subject.exit_code).to eq(exit_code)
      expect(subject.stdout).to eq(stdout)
      expect(subject.stderr).to eq(stderr)
    end
  end
end