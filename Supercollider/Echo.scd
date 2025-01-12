// Boot / startup settings for SuperCollider
(
// boot a synthesis/DSP server on localhost
(
Server.local.boot;
~dspServer = Server.local;
Server.default = ~dspServer;
)
// setting the audio output busses
(
~c_AUDIO_L_BUS = 0;
~c_AUDIO_R_BUS = ~c_AUDIO_L_BUS + 1;
~c_AUDIO_ATTENUATION = (0.75).linexp (0, 1, 1e-04, 1);
)
// setup the input variable of the library
(
~csp = ComputedSoundPrimitives_dummy.new;
)
)

// setup the Synthesis Function
(
~echo_testSynthDef = SynthDef
( name: "echo_testSynth",
ugenGraphFunc: // the working function of the algorithm
{

}

);
)
