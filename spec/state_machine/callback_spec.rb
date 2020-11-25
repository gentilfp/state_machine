require 'spec_helper'

RSpec.describe Callback do
  subject { described_class.new(code_block) }
  let(:code_block) do
    -> { puts 'hello from callback' }
  end

  describe '#initialize' do
    it { expect(subject.code_block) == code_block }
  end

  describe '.call' do
    it 'runs code' do
      expect { subject.call }.to output("hello from callback\n").to_stdout
    end
  end
end
