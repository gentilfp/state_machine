# frozen_string_literal: true

RSpec.describe StateMachine::MethodDefiner do
  before(:all) do
    class TesteMethodDefinerClass
      include StateMachine

      state :pending, initial: true
      state :done

      event :run do
        transitions from: :pending, to: :done
      end
    end
  end

  let(:state_machine) do
    {
      run: {
        pending: double(:transition)
      }
    }
  end

  before { described_class.new(state_machine, TesteMethodDefinerClass) }

  subject { TesteMethodDefinerClass.new }

  context 'state methods' do
    it { expect(subject).to respond_to(:pending?) }
    it { expect(subject).to respond_to(:done?) }
  end

  context 'transition methods' do
    context 'can transit methods' do
      it { expect(subject).to respond_to(:can_run?) }
    end

    context 'transit methods' do
      it { expect(subject).to respond_to(:run!) }
    end
  end
end
