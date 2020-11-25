require 'spec_helper'

RSpec.describe StateMachine do
  class StateMachineTestClass
    include StateMachine

    state :standing
    state :walking
    state :running
  end

  context 'states' do
    subject { StateMachineTestClass.new }

    context 'state question (?) method definition' do
      it { expect(subject.respond_to?(:standing?)).to be_truthy }
      it { expect(subject.respond_to?(:walking?)).to be_truthy }
      it { expect(subject.respond_to?(:running?)).to be_truthy }
    end
  end
end
