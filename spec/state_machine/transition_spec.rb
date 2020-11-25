require 'spec_helper'

RSpec.describe Transition do
  subject { described_class.new(:from_state, :to_state, :guard_clause) }

  it 'responds to its attributes' do
    expect(subject.from).to eq :from_state
    expect(subject.to).to eq :to_state
    expect(subject.guard).to eq :guard_clause
  end
end
