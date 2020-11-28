# frozen_string_literal: true

require 'spec_helper'

RSpec.describe StateMachine do
  class StateMachineTestClass
    include StateMachine

    state :standing, initial: true
    state :walking
    state :running

    event :walk do
      transitions from: :standing, to: :walking, when: -> { 1 != 2 }
    end

    event :run do
      transitions from: %i[standing walking], to: :running, when: -> { 1 == 2 }
    end

    event :hold do
      transitions from: %i[walking running], to: :standing, when: :method_guard
    end

    on_enter :walking do
      puts 'entering walking state'
    end

    on_leave :running do
      puts 'leaving running state'
    end

    on_transition :hold do
      puts 'running hold transition'
    end

    def method_guard
      true
    end
  end

  context 'defining states' do
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

    context 'with more than one initial state allowed' do
      subject do
        class StateMachineTestClass
          state :extra_initial, initial: true
        end
      end

      it 'raises error' do
        expect { subject }.to raise_error(StateMachine::Parser::OnlyOneInitialStateAllowed)
      end
    end

    context 'with an invalid state in transitions' do
      context 'when "from" state is invalid' do
        subject do
          class StateMachineTestClass
            event :stop do
              transitions from: :foo, to: :standing
            end
          end
        end

        it 'raises error' do
          expect { subject }.to raise_error(StateMachine::Parser::InvalidStateInTransition)
        end
      end

      context 'when "to" state is invalid' do
        subject do
          class StateMachineTestClass
            event :stop do
              transitions from: :walking, to: :bar
            end
          end
        end

        it 'raises error' do
          expect { subject }.to raise_error(StateMachine::Parser::InvalidStateInTransition)
        end
      end
    end

    context 'when no initial state is found' do
      subject do
        class MachineWithoutInitialState
          include StateMachine

          state :foo
          state :bar
        end.new
      end

      it 'raises error' do
        expect{ subject }.to raise_error(StateMachine::NoInitialStateFound)
      end
    end
  end

  context 'registering events and transitions' do
    subject { StateMachineTestClass.new }

    context 'registering events and state transitions' do
      it 'registers hash with events' do
        expect(subject.state_machine.events).to include(:walk, :run, :hold)
      end

      it 'registers events with transions' do
        expect(subject.state_machine.events[:walk]).to include :standing
        expect(subject.state_machine.events[:run]).to include :standing
        expect(subject.state_machine.events[:run]).to include :walking
        expect(subject.state_machine.events[:hold]).to include :walking
        expect(subject.state_machine.events[:hold]).to include :running
      end

      it 'registers guard clause' do
        expect(subject.state_machine.events[:walk][:standing].guard).to be_a Proc
      end
    end
  end

  context 'simple transition' do
    subject { StateMachineTestClass.new(:standing) }

    it 'transits from one state to another' do
      subject.walk!
      expect(subject.state_machine.current_state).to eq :walking
    end

    it 'transits when guard clause is a method that returns true' do
      subject.walk!
      subject.hold!
      expect(subject.state_machine.current_state).to eq :standing
    end

    it 'raises error when transition is invalid' do
      expect { subject.hold! }.to raise_error(StateMachine::InvalidTransition)
    end

    it 'raises error if guard clause is violated' do
      expect { subject.run! }.to raise_error(StateMachine::TransitionGuardClauseViolated)
    end
  end

  context 'can transit method' do
    subject { StateMachineTestClass.new(:walking) }

    it 'returns true if transition is allowed' do
      expect(subject.can_hold?).to be_truthy
    end

    it 'returns false if transition is not allowed' do
      expect(subject.can_walk?).to be_falsey
    end
  end

  context 'defining callbacks' do
    subject { StateMachineTestClass.new }

    context 'when entering a state' do
      it { expect(subject.state_machine.callbacks[:enter_state][:walking]).to be_a Callback }
    end

    context 'when leaving a state' do
      it { expect(subject.state_machine.callbacks[:leave_state][:running]).to be_a Callback }
    end

    context 'when running a transition' do
      it { expect(subject.state_machine.callbacks[:transition][:hold]).to be_a Callback }
    end
  end

  context 'running callbacks' do
    context 'when leaving a state' do
      subject { StateMachineTestClass.new(:running) }

      it 'runs callback before transition' do
        expect { subject.hold! }.to output(/leaving running state/).to_stdout
      end
    end

    context 'when running a transition' do
      subject { StateMachineTestClass.new(:walking) }

      it 'runs callback during transition' do
        expect { subject.hold! }.to output(/running hold transition/).to_stdout
      end
    end

    context 'when entering a state' do
      subject { StateMachineTestClass.new }

      it 'runs callback after transition' do
        expect { subject.walk! }.to output(/entering walking state/).to_stdout
      end
    end
  end
end
