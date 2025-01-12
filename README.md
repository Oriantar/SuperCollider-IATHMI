# SuperCollider-IATHMI

In dit project gaan wij voor een Human Machine Interaction vak een Echo effect maken in SuperCollider

# Documentation of the Echo function

- echoproc

  - Echo Processor primitive.
    - Controllable delay loop including an arbitrarily specified echo processing element.
    - Returns a UGen graph according to specification.
  - arguments

    - i_output = \on, // on/off switch to quickly monitor influence in wider synthesis network
    - i_delayIntType = \cubIntDelay, // type of interpolation used in delay: \unIntDelay, \linIntDelay, \cubIntDelay
    - i_maxDelay = 1, // maximum delay time (s)
    - i_echoProcDefFunc = { arg a_in; a_in; }, // function returning one-input, -output UGen graph
    - a_input = nil, // signal to be echoed, processed
    - a_delay = 0.1, // delay time (s); within the range [ControlDur.ir, i_maxDelay]
    - a_fbLevel = 0.5; // internal feedback attenuation factor

  - var
    uGenGraph = nil; // the unit generator graph to be constructed
