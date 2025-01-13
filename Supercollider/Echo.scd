// Boot / startup settings for SuperCollider
(
// boot a synthesis/DSP server on localhost

Server.local.boot;
~dspServer = Server.local;
Server.default = ~dspServer;

// setting the audio output busses

~c_AUDIO_L_BUS = 0;
~c_AUDIO_R_BUS = ~c_AUDIO_L_BUS + 1;
~c_AUDIO_ATTENUATION = (0.75).linexp (0, 1, 1e-04, 1);

// setup the input variable of the library

~csp = ComputedSoundPrimitives_dummy.new;
)
~sound = SinOsc.ar (freq: 440);
// setup the Synthesis Function
~sound.postln;
"Input signal: ".postln;
(
~testSynthDef = SynthDef
( name: "echo_testSynth",
ugenGraphFunc: // the working function of the algorithm
{
var out_sig_l = ~csp.echoproc
(
i_output: \on,
i_delayIntType: \cubIntDelay,
i_maxDelay: 1,
i_echoProcDefFunc: { arg a_in; a_in; },
a_input: ~sound,
a_delay: 0.1,
a_fbLevel: 0.5,
);

// Debugging: Print the output signal
"Output signal: ".postln;
out_sig_l.postln;
// var out_sig_r = out_sig_l;
// Out.ar (bus: ~c_AUDIO_L_BUS, channelsArray: ~c_AUDIO_ATTENUATION _ out_sig_l);
// Out.ar (bus: ~c_AUDIO_R_BUS, channelsArray: ~c_AUDIO_ATTENUATION _ out_sig_r);
}
);
)
~csp.mce.postln;

~testSynth = ~echo_testSynthDef.play;

~testSynth.free;
~dspServer.queryAllNodes;

~dspServer.quit;
