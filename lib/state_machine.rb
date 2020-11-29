# frozen_string_literal: true

require 'state_machine/version'
require 'state_machine/transition'
require 'state_machine/callback'
require 'state_machine/parser'
require 'state_machine/state_machine'
require 'state_machine/machine'
require 'state_machine/validators/base'
require 'state_machine/validators/invalid_transition'
require 'state_machine/validators/transition_guard_clause_violated'
require 'state_machine/method_definer'

module StateMachine
  class InvalidTransition < StandardError; end
  class TransitionGuardClauseViolated < StandardError; end
  class NoInitialStateFound < StandardError; end
end
