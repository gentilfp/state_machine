# frozen_string_literal: true

require 'state_machine/version'
require 'state_machine/transition'
require 'state_machine/callback'
require 'state_machine/parser'

module StateMachine
  class InvalidTransition < StandardError; end
  class TransitionGuardClauseViolated < StandardError; end

  def self.included(base)
    base.extend StateMachine::Parser
  end

  def initialize(initial_state = nil)
    initial_state(initial_state)
    define_methods
  end

  def transit(event, transition)
    raise InvalidTransition if events[event][current_state].nil?
    raise TransitionGuardClauseViolated unless transition.valid_guard?(self)

    run_before_callbacks(event)

    @current_state = transition.to

    run_after_callbacks
  end

  def can_transit?(event, transition)
    !events[event][current_state].nil? && transition.valid_guard?(self)
  end

  def current_state
    @current_state ||= @initial_state
  end

  def states
    @states ||= events.keys.flat_map { |event| events[event].keys }.uniq
  end

  def events
    @events ||= self.class.instance_variable_get(:@events)
  end

  def callbacks
    @callbacks ||= self.class.instance_variable_get(:@callbacks)
  end

  private

  def run_before_callbacks(event)
    callbacks[:leave_state][@current_state]&.call
    callbacks[:transition][event]&.call
  end

  def run_after_callbacks
    callbacks[:enter_state][@current_state]&.call
  end

  def define_methods
    define_state_methods
    define_event_methods
  end

  def initial_state(initial_state)
    @initial_state ||= initial_state || self.class.instance_variable_get(:@initial_state)
  end

  def define_state_methods
    states.each do |state|
      define_singleton_method("#{state}?") do
        current_state == state
      end
    end
  end

  def define_event_methods
    events.each do |event, transitions|
      transitions.each_key do |from|
        define_singleton_method("#{event}!") do
          transit(event, transitions[from])
        end

        define_singleton_method("can_#{event}?") do
          can_transit?(event, transitions[from])
        end
      end
    end
  end
end
