# StateMachine

This is a very simple library that allows defining state machines to Ruby classes.
The project is still under construction and the features available are:

```
- Define states using `state`
- Define events using `event`
  * it receives a name and a block containing the transition for that specific event
- Define transition between states using `transitions`
  * transitions
    > it receives a name as first argument
    > the following arguments must contain from: and to:, which represents states
    > it is possible to define a guard_clause using `when` that can be a lambda or a method call
- There are 3 types of callbacks
  * on_enter: triggered when entering a state
  * on_leave: triggered after leaving a state
  * on_transition: triggered when a specific transition is run
```
## Installation

In order to help things out, the project itself is dockerized and can be run using only docker with a simple script in the root folder.

```
$ ./state_machine
This is the state_machine script you can use to run console, bash, tests and so on.

Usage: state_machine <option> <arguments>

Available options:
 setup: build docker image
 start: run the application
 run: run given command inside the container
 tests: run tests
 console: start ruby console
 rubocop: runs statis code analyzer
 sh: bring up a sh session
 diagram: generates a sample diagram for a state machine

Hope you have fun!
```

### Setup
```
$ ./state_machine setup
Building state_machine
...
...
Successfully built 9cd3b9699a63
Successfully tagged state_machine:latest
```

### Tests
Tests are written using `rspec` and can be run using docker with the following command:
```
$ ./state_machine tests
```
or simply (make sure to run `$ bundle install before`)
```
$ rspec .
```
### Sample Diagram
The library depends on GraphViz gem in order to generate diagrams for the state machines.
There is a sample diagram that can be generated with:
```
$ ./state_machine diagram
```
The state machine definition can be found at `./bin/sample_diagram` and the image file at `./tmp/TIMESTAMP_sample_diagram.png`

## Usage
Make sure to include `StateMachine` in your class.
Here is an example

```
class Processor
  include StateMachine

  state :pending, initial: true
  state :running
  state :done
  state :error

  event :run
    transition from: :pending, to: :run, when -> { ready_to_run? }
  end

  event :fail
    transition from: [:pending, :running], to: :error
  end

  on_enter :done do
    log('finished processing')
  end

  on_transition :fail do
    alert('failed processing)
  end

  def ready_to_run?
    # your code
  end
end
```

## Design
There are basically two modules responsible for implementing the state machine.
* Parser module is responsible for implementing the methods :state, :event, :transition and the callbacks. It parses data and registers them basically in hashes that can be accessed directly when changing state machine states;
  * it raises `OnlyOneInitialStateAllowed` if initial state is defined more than once;
    * initial state can be configured in the state machine or when initializing the class, the precedence is the latest;
  * it raises `InvalidStateInTransition` if a particular transition is defined to use a state that has not been defined before;
* StateMachine module is responsible for gathering the data parsed from Parser and defining methods that can be used in your own class, such as:
  * can_TRANSITION? - if transition can be made regarding if it exists or the guard clause returns true;
  * STATE? - if the machine is in this state, returns true or false;
  * EVENT! - makes the transition from current_state to the transition definition state, it will raise `InvalidTransition` if transition is not defined or `TransitionGuardClauseViolated` if guard clause fails.
* StateMachine is also responsible for running callbacks parsed by Parser.
  * When making a particular transition, the callbacks are run in the following order:
    * run leave current state callback
    * run transition callback
    * change current state to the destination state
    * run enter state callback for the destination on

I've dedicated only a couple of days to this project so it has a lot to improve.

### Implementation
The first thing that was thought and designed was the data structure for the state machine, it basically uses two hashes, one for the events and the other for the callbacks.
This way, it is a little bit more expensive to parse but faster to access and make the specific transitions or running callbacks.

For the following class:
```
class StateMachineExampleClass
  include StateMachine

  state :standing, initial: true
  state :walking
  state :running

  event :walk do
    transitions from: :standing, to: :walking
  end

  event :run do
    transitions from: [:standing, :walking], to: :running, when: :test_when_clause
  end

  event :hold do
    transitions from: [:walking, :running], to: :standing, when: -> { 1 != 2 }
  end

  on_enter :walking do
    puts "entering walking state"
  end

  on_leave :running do
    puts "leaving running state"
  end

  on_transition :hold do
    puts "running hold transition"
  end

  def test_when_clause
    false
  end
end
```
It will generate the following data structures:

The events Hash
```
{
:walk => {
    :standing => <Transition @from=:standing, @to=:walking, @guard=nil>
  },
:run => {
    :standing => <Transition @from=:standing, @to=:running, @guard=:test_when_clause>,
    :walking => <Transition @from=:walking, @to=:running, @guard=:test_when_clause>
  },
:hold=>{
    :walking => <Transition @from=:walking, @to=:standing, @guard=<Proc (irb):17 (lambda)>>,
    :running => <Transition @from=:running, @to=:standing, @guard=<Proc (irb):17 (lambda)>>
  }
}
```

The callbacks Hash
```
{
  :enter_state => { :walking => <Callback @code_block=#<Proc:0x0000556c46d00bf8 (irb):20>> },
  :leave_state => { :running => <Callback @code_block=#<Proc:0x0000556c46d00b58 (irb):24>> },
  :transition => { :hold => <Callback @code_block=#<Proc:0x0000556c46d00a90 (irb):28>> }
}
```

## Where to improve?
There are a few of things that can be refactored and extracted:
* move transition validation to a validator service or anything like so it would remove the duplicated method call in transit and can_transit? `(state_machine:22)`
* remove the dependencies that Transaction class has to the object when running a method guard clause `(state_machine:33)`
* refactor callbacks so you have an object that can be called instead of running directly the lambda `(state_machine:54)`
* extract callbacks and transition from the statemachine main module so they can be treated separately
* more unit tests, I've decided to cover the majority of cases using the integration tests
