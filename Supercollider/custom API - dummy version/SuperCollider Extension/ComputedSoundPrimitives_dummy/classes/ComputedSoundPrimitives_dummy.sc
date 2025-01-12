
ComputedSoundPrimitives_dummy
/* container class for synthesis primitives,
   in the order of a possible default workflow:
   - bo       : Basic Oscillator
   - curver   : Curver
   - add/mul  : signal mixing/modulation by addition/multiplication
   - xfade    : crossfade
   - bf       : Basic Filter
   - hr       : Harmonic Replicator
   - bgg      : Basic Grain Generator
   - sgg      : Stochastic Grain Generator
   - mce      : Multistage Curve Envelope
   - echoproc : Echo Processor
   - stereo   : stereo placement
*/
{
  *new
  /* constructor */
  {
    ^super.new;
  }


  bo
  /* Basic Oscillator primitive.
     Returns a UGen graph according to specification.
  */
  {
    arg
      i_output = \on,      // on/off switch to quickly monitor influence in wider synthesis network
      i_type = \pulse,     // waveform to be used - (a)periodic function identifier:
                           //                       \pulse, \impulse, \saw, \triangle, \sine, \noise
      i_polar = \bipolar,  // unipolar [0,1] or bipolar [-1,+1] amplitude range
      i_bLim = \nonlim,    // band limiting: anti-aliasing (for high (affects low) frequencies)
      a_freq = 100,        // waveform periods per second
      a_phReset = 0,       // trig resets waveform phase - if band limiting is off
      a_pWidth = 0.5,      // fraction of Pulse wave cycle during which amplitude is high
      a_impDur = 1/44100,  // fraction (s) of Impulse wave cycle during which amplitude is high
                           // - Default: shortest impulse producible with CD-quality hardware.
      i_nTriPartials = 16; // number of partials in band limited Triangle waveform
                           // - Allows a trade-off between CPU load and timbre.
                           // - E.g. 170 Hz triangle, sr 44.1 kHz: up to 33 partials add audibly.
    var
      uGenGraph = nil; // the unit generator graph to be constructed

    ^uGenGraph;

  } // (end of bo: Basic Oscillator primitive)


  curver
  /* Curver primitive.
     Reciprocal curvature mapping of unipolar signals.
     Returns a UGen graph according to specification.
  */
  {
    arg
      i_output = \on,   // on/off switch to quickly monitor influence in wider synthesis network
      a_unipolar = nil, // input signal in range [0, 1], to be mapped according to a curve
      a_curvature = 0;  // curvature [-1..0..1] for [hollow..linear..convex] mappings

    var
      uGenGraph = nil; // the unit generator graph to be constructed

    ^uGenGraph;

  } // (end of curver: Curver primitive)


  add
  /* A notation for mixing one signal with other signals.
     - May often use attenuated inputs, e.g. "p.add (\on, signal1 * 0.5, signal2 * 0.3, ...)".
     Returns a UGen graph according to specification.
  */
  {
    arg
      i_output = \on // on/off switch to quickly monitor influence in wider synthesis network
      ... a_signals; // one or more signals to add

    var
      uGenGraph = nil; // the unit generator graph to be constructed

    ^uGenGraph;

  } // (end of add primitive)


  mul
  /* A notation for multiplying one signal by other signals.
     - For unrestricted input signals, this corresponds to ring modulation (RM).
     - For input signals converted to their absolute value, to amplitude modulation (AM).
       - E.g. "p.mul (\on, signal1, signal2.abs, ...)".
     Returns a UGen graph according to specification.
  */
  {
    arg
      i_output = \on // on/off switch to quickly monitor influence in wider synthesis network
      ... a_signals; // one or more signals to multiply

    var
      uGenGraph = nil; // the unit generator graph to be constructed

    ^uGenGraph;

  } // (end of mul primitive)


  xfade
  /* Crossfade primitive, for linear fading between two input signals.
     Returns a UGen graph according to specification.
  */
  {
    arg
      i_output = \on,  // on/off switch to quickly monitor influence in wider synthesis network
      a_fade = nil,    // control signal: [0,1] fades between a_signal0 and a_signal1
      a_signal0 = nil,
      a_signal1 = nil;

    var
      uGenGraph = nil; // the unit generator graph to be constructed

    ^uGenGraph;

  } // (end of xfade primitive)


  bf
  /* Basic Filter primitive.
     Switchable lowpass / highpass / bandpass / bandreject filter, -12 dB/octave,
     with frequency and resonance inputs.
     Returns a UGen graph according to specification.
  */
  {
    arg
      i_output = \on, // on/off switch to quickly monitor influence in wider synthesis network
      i_type = \lp,   // filter type to be used: \lp, \hp, \bp, \br
      a_signal = nil, // input signal to be filtered
      a_freq = 100,   // cutoff or center frequency (Hz)
      a_reso = 1;     // "1/Q": resonance bandwidth = a_freq * a_reso

    var
      uGenGraph = nil; // the unit generator graph to be constructed

    ^uGenGraph;

  } // (end of bf: Basic Filter primitive)


  hr
  /* Harmonic Replicator primitive.
     Replication and harmonic control of sound processing elements.
     Returns a UGen graph according to specification.
  */
  {
    arg
      i_output = \on, // on/off switch to quickly monitor influence in wider synthesis network
      i_procEltDefFunc = nil, // function returning UGen graph parametrized by 1 frequency argument
      i_nProcElts = 3, // number of processing elements to give output in parallel
      i_freqRangeType = \expFreqRange, // type of frequency range used for harmonic control:
                                       //     \linFreqRange, \expFreqRange
      i_freqBoundType = \octaveBound,  // how a_freqBound delimits the range based on a_baseFreq:
                                       //     \addBound, \mulBound, \octaveBound
      i_ampRangeType = \noAmpRange,    // type of amplitude range used for harmonic control:
                                       //     \noAmpRange, \linAmpRange, \expAmpRange
      i_ampBoundType = \mulBound,      // how a_ampBound delimits based on amplitude 1 for base frequency:
                                       //     \mulBound, \dbBound
      a_baseFreq = 100, // base frequency, for the first processing element
      a_freqBound = 2,  // boundary frequency (relative), for the last processing element
      a_freqCurve = 0,  // frequency curvature [-1..0..1] for intermediate processing elements
      a_ampBound = 1,   // boundary amplitude (relative), for the last processing element
      a_ampCurve = 0;   // amplitude curvature [-1..0..1] for intermediate processing elements

    var
      uGenGraph = nil; // the unit generator graph to be constructed

    ^uGenGraph;

  } // (end of hr: Harmonic Replicator primitive)


  bgg
  /* Basic Grain Generator primitive.
     - Uses a fixed, Hanning-type grain envelope.
     - Based on earlier experiences with Granulab and Density software,
       then writing and using my Dervish and Percussive Granular Resampler software.
     Returns a UGen graph according to specification.
  */
  {
    arg
      i_output = \on, // on/off switch to quickly monitor influence in wider synthesis network
      a_trig = Impulse.ar (10), // trigger starts a grain, according to snapshot of:
      a_srcBufNum = -1,         // - source sample series for grain (mono buffer)
      a_srcBufPos = 0,          // - grain envelope center's position within series (s)
      a_grainDur = 0.1,         // - grain duration (s)
      a_grainAmp = 1,           // - grain amplitude (linear)
      a_grainPlayRate = 1;      // - source buffer playback rate for grain (linear, bipolar)

    var
      uGenGraph = nil; // the unit generator graph to be constructed

    i_output.switch
    (
      \off,
      {
        uGenGraph = 0; // switching off means zero signal output
      },

      \on,
      {
        uGenGraph = TGrains.ar
        ( numChannels: 2, // (stereo is minimum for TGrains)
          interp: 4, // (cubic interpolation)
          trigger: a_trig,
          bufnum: a_srcBufNum,
          rate: a_grainPlayRate,
          centerPos: a_srcBufPos,
          dur: a_grainDur,
          pan: -1, // (hard left panning)
          amp: a_grainAmp
        )[0]; // (use left output channel only)
      }

    );

    ^uGenGraph;

  } // (end of bgg: Basic Grain Generator primitive)


  sgg
  /* Stochastic Grain Generator primitive.
     Grain generation with controlled randomization of parameters.
     Uses a fixed, Hanning-type grain envelope.
     Returns a UGen graph according to specification.
  */
  {
    arg
      i_output = \on, // on/off switch to quickly monitor influence in wider synthesis network

      // trigger individual grains via oscillator, or directly:
      a_trigFreq = 10,       // grain triggering frequency (Hz)
      a_trigFreq_rndAmp = 0, // ...random modulation amplitude (Hz)
      a_trigReset = 0,       // trig resets grain trigger oscillator; triggers a single grain

      // each trigger starts a grain, according to snapshot of:
      a_srcBufNum = -1,           // - source sample series for grain (mono buffer)
      a_srcBufPos = 0,            // - grain envelope center's position within series (s)
      a_srcBufPos_rndAmp = 0,     //   ...random modulation amplitude (s)
      a_grainDur = 0.1,           // - grain duration (s)
      a_grainDur_rndAmp = 0,      //   ...random modulation amplitude (s)
      a_grainRelAmp = 0,          // - grain amplitude (relative, dB)
      a_grainRelAmp_rndAmp = 0,   //   ...random modulation amplitude (dB)
      a_grainRelPitch = 0,        // - source buffer playback rate for grain (relative, octaves)
      a_grainRelPitch_rndAmp = 0, //   ...random modulation amplitude (octaves)

      // UGen graph (audio rate, [-1,1] output) to be used for randomization:
      i_rndFunc = { this.bo (\on, \noise, \bipolar, \nonlim); }; // default: white noise

    var
      uGenGraph = nil; // the unit generator graph to be constructed

    ^uGenGraph;

  } // (end of sgg: Stochastic Grain Generator primitive)


  mce
  /* Multistage Curve Envelope primitive.
     Returns a UGen graph according to specification.
  */
  {
    arg
      i_output = \on,   // on/off switch to quickly monitor influence in wider synthesis network
      i_envSpec = nil,  // Env object specifying the envelope
                        // ^ Give stage 1 duration 0 & the initialization level again as target,
                        //   since EnvGen.ar skips the initial envelope value when retriggered.
                        //   For example:
                        //     ~envSpec = Env.new   // envelope specification:
                        //     ( [ 0.5, 0.5, 1.0 ], // target levels
                        //       [        0, 0.1 ], // durations
                        //       [        0,   0 ]  // curvatures
                        //     ).plot;
      a_trig = 0.0,     // trig input for the envelope
      a_durScale = 1.0, // duration scaling (s/s); polled-then-held for each envelope stage
      i_freeSynthWhenDone = \off;

    var
      uGenGraph  = nil; // the unit generator graph to be constructed

    ^uGenGraph;

  } // (end of mce: Multistage Curve Envelope primitive)


  echoproc
  /* Echo Processor primitive.
     Controllable delay loop including an arbitrarily specified echo processing element.
     Returns a UGen graph according to specification.
  */
  {
    arg
      i_output = \on, // on/off switch to quickly monitor influence in wider synthesis network
      i_delayIntType = \cubIntDelay, // type of interpolation used in delay: \unIntDelay, \linIntDelay, \cubIntDelay
      i_maxDelay = 1, // maximum delay time (s)
      i_echoProcDefFunc = { arg a_in; a_in; }, // function returning one-input, -output UGen graph
      a_input = nil, // signal to be echoed, processed
      a_delay = 0.1, // delay time (s); within the range [ControlDur.ir, i_maxDelay]
      a_fbLevel = 0.5; // internal feedback attenuation factor

    var
      uGenGraph = nil; // the unit generator graph to be constructed

    ^uGenGraph;

  } // (end of echoproc: Echo Processor primitive)


  stereo
  /* Stereo Placement primitive.
     Returns a UGen graph according to specification.
  */
  {
    arg
      i_output = \on, // on/off switch to quickly monitor influence in wider synthesis network
      i_spdelay = \cubIntSpDelay, // spatial delay type: \noSpDelay,     \unIntSpDelay,
                                  //                     \linIntSpDelay, \cubIntSpDelay
      i_pan = \linPan,            // panning type:       \noPan, \linPan, \powPan
      a_mono = nil, // the mono input signal
      a_lr = nil; // control signal: [-1,+1] for stereo placement from left to right

    var
      uGenGraph = nil; // the unit generator graph to be constructed

    ^uGenGraph;

  } // (end of stereo primitive)

} // (end of class ComputedSoundPrimitives_dummy)
