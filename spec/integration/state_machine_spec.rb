require 'spec_helper'

RSpec.describe StateMachine do
  class StateMachineTestClass
    include StateMachine

    state :standing, initial: true
    state :walking
    state :running
  end

  context 'states' do
    subject { StateMachineTestClass.new(initial_state) }
    let(:initial_state) { nil }

    context 'state question (?) method definition' do
      it { expect(subject.respond_to?(:standing?)).to be_truthy }
      it { expect(subject.respond_to?(:walking?)).to be_truthy }
      it { expect(subject.respond_to?(:running?)).to be_truthy }
    end

    context 'initial and current state definition' do
      context 'when initial state is set by state machine config' do
        it { expect(subject.standing?).to be_truthy }
        it { expect(subject.walking?).to be_falsey }
        it { expect(subject.running?).to be_falsey }
      end

      context 'when initial state is set by class initialization' do
        let(:initial_state) { :walking }

        it { expect(subject.standing?).to be_falsey }
        it { expect(subject.walking?).to be_truthy }
        it { expect(subject.running?).to be_falsey }
      end
    end
  end
end
