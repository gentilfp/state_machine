# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Transition do
  subject { described_class.new(:from_state, :to_state, guard_clause) }
  let(:guard_clause) { nil }

  it 'responds to its attributes' do
    expect(subject.from).to eq :from_state
    expect(subject.to).to eq :to_state
    expect(subject.guard).to eq nil
  end

  describe '.valid_guard?' do
    context 'when guard is a method call' do
      let(:guard_clause) { :foo }
      let(:obj) { double(:sender_object) }

      it 'calls sender method' do
        expect(obj).to receive(:send).with(:foo) { true }

        subject.valid_guard?(obj)
      end
    end

    context 'when guard is a Proc' do
      let(:guard_clause) { -> { 1 != 2 } }

      it 'calls sender method' do
        expect(subject.valid_guard?).to be_truthy
      end
    end
  end
end
