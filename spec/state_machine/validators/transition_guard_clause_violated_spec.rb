# frozen_string literal: true

RSpec.describe StateMachine::Validators::TransitionGuardClauseViolated do
  subject { described_class.new(state_machine, transition: transition, obj: obj) }
  let(:state_machine) { double(:state_machine) }
  let(:transition) { Transition.new(from: :foo, to: :bar, guard: :guard_method) }
  let(:obj) { double(:obj) }

  describe '.valid?' do
    it 'runs method against instance' do
      expect(obj).to receive(:guard_method) { true }
      expect(subject.valid?).to be_truthy
    end
  end

  describe 'fail!' do
    it 'raises exception' do
      expect { subject.fail! }.to raise_error(::StateMachine::TransitionGuardClauseViolated)
    end
  end
end
