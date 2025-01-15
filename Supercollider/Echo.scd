// Boot / startup settings for SuperCollider 2

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

~sound = ~grainSrcBuf = Buffer.read (~dspServer, Platform.resourceDir +/+ "sounds/SinedPink.aiff");
// setup the Synthesis Function
"Input signal: ".postln;
~sound.postln;
l = 0.5;
d = 0.1;
(
~testSynthDef = SynthDef(
    name: "echo_testSynth",
    ugenGraphFunc: // the working function of the algorithm
    {
		var inSig, outL, outR;

		inSig = PlayBuf.ar(1, ~sound.bufnum, loop: 1);

		outL = ~csp.echoproc(
            i_output: \on,
            i_delayIntType: \cubIntDelay,
            i_maxDelay: 1,
            i_echoProcDefFunc: { arg a_in; a_in; },
            a_input: ~sound,
            a_delay: d,
            a_fbLevel: l,
        );


		outR = outL;
		Out.ar (bus: ~c_AUDIO_L_BUS, channelsArray: ~c_AUDIO_ATTENUATION * outL);
		Out.ar (bus: ~c_AUDIO_R_BUS, channelsArray: ~c_AUDIO_ATTENUATION * outR);
}
);
)
(
w = Window.new("Echo GUI", Rect(200,200,255,100));
l = Slider.new(w,Rect(5,0,150,30));
~l_label = StaticText.new(w, Rect(5, 30, 150, 20)).string_("Feedback Level");

d = Slider.new(w,Rect(5,50,150,30));
~d_label = StaticText.new(w, Rect(5, 80, 150, 20)).string_("Delay Level");
c = CompositeView.new(w,Rect(20,35,100,60));
w.front;
)

~testSynth = ~echo_testSynthDef.play;
~testSynth.set (l, l.value);
~testSynth.set (d, d.value);
~testSynth.free;
~dspServer.queryAllNodes;

~dspServer.quit;
