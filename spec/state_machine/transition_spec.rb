# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Transition do
  subject { described_class.new(from: :from_state, to: :to_state, guard: guard_clause) }
  let(:guard_clause) { nil }

  context 'attributes' do
    it { expect(subject.from).to eq :from_state }
    it { expect(subject.to).to eq :to_state }
    it { expect(subject.guard).to eq nil }
  end

  describe '.valid_guard?' do
    context 'when guard is a method call' do
      let(:guard_clause) { :foo }
      let(:obj) { double(:sender_object, foo: true) }

      it 'calls sender method' do
        expect(subject.valid_guard?(obj)).to be_truthy
      end
    end

    context 'when guard is a Proc' do
      let(:guard_clause) { -> { 1 != 2 } }
      let(:obj) { nil }

      it 'calls sender method' do
        expect(subject.valid_guard?).to be_truthy
      end
    end
  end
end
