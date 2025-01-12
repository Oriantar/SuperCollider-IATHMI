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


// setup the Synthesis Function
(
~testSynthDef = SynthDef
( name: "echo_testSynth",
ugenGraphFunc: // the working function of the algorithm
{
//var out_sig_l = ~csp.echoproc
//( \on,
//i_delayIntType: \cubIntDelay,
//i_maxDelay: 1,
//i_echoProcDefFunc: { arg a_in; a_in; },
//a_input: SinOsc.ar (freq: 440),
//a_delay: 0.1,
//a_fbLevel: 0.5

var out_sig_l = SinOsc.ar (freq: 230);

 Out.ar (bus: ~c_AUDIO_L_BUS, channelsArray: ~c_AUDIO_ATTENUATION * out_sig_l);

}
 );
)
~csp.mce.postln;

~testSynth = ~testSynthDef.play;

~testSynth.free;
~dspServer.queryAllNodes;

~dspServer.quit;
