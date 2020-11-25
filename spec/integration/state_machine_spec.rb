require 'spec_helper'

RSpec.describe StateMachine do
  class StateMachineTestClass
    include StateMachine

    state :standing, initial: true
    state :walking
    state :running

    event :walk do
      transitions from: :standing, to: :walking
    end

    event :run do
      transitions from: [:standing, :walking], to: :running
    end

    event :hold do
      transitions from: [:walking, :running], to: :standing
    end
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

  context 'register events and transitions' do
    subject { StateMachineTestClass.new }
    let(:events) do
      {
        walk: { standing: :walking },
        run:  { standing: :running,
                walking: :running },
        hold: { walking: :standing,
                running: :standing}
      }
    end

    context 'registering events and state transitions' do
      it 'registers hash with events' do
        expect(subject.events).to eq events
      end
    end
  end

  context 'simple transition' do
    subject { StateMachineTestClass.new(:standing) }

    it 'transits from one state to another' do
      subject.walk!
      expect(subject.current_state).to eq :walking
    end

    it 'raises error when transition is invalid' do
      expect { subject.hold! }.to raise_error('invalid transition')
    end
  end
end
