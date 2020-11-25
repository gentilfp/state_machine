# frozen_string_literal: true

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
      expect { subject.call }.to output(/hello from callback/).to_stdout
    end

    context 'when code block is empty' do
      let(:code_block) { nil }

      it 'does nothing' do
        expect(subject.call).to be_nil
      end
    end
  end
end
