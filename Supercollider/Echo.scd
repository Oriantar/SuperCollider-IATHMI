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

~currentDir = thisProcess.nowExecutingPath.dirname;
~sound = ~grainSrcBuf = Buffer.read (~dspServer, ~currentDir +/+ "sounds/Joehoe.aiff");
// setup the Synthesis Function
"Input signal: ".postln;
~sound.postln;
l = 0.1; // De intensiteit / hardheid van de echo
d = 0.5; // Hoe lager hoe sneller de echo zichzelf herhaalt

// Echo processing function implementing y[n]=x[n]+α⋅y[n−D]
(~echoproc = { arg i_output = \on, i_delayIntType = \cubIntDelay, i_maxDelay = 1,
    i_echoProcDefFunc, a_input, a_delay, a_fbLevel;

    var delayedSignal;
    var processedSignal;

    // Convert delay time to samples based on interpolation type
    var delayLine = switch(i_delayIntType,
        \noIntDelay, { DelayN.ar(a_input, i_maxDelay, a_delay) },
        \linIntDelay, { DelayL.ar(a_input, i_maxDelay, a_delay) },
        \cubIntDelay, { DelayC.ar(a_input, i_maxDelay, a_delay) }
    );

    // Apply the echo formula y[n]=x[n]+α⋅y[n−D]
    processedSignal = Mix([a_input, (a_fbLevel * delayLine)]);

    // Apply any additional processing if provided
    processedSignal = i_echoProcDefFunc.value(processedSignal);

    // Output routing
    switch(i_output,
        \on, { processedSignal },
        \off, { a_input },
        { a_input } // default case
    );
};)

(
~testSynthDef = SynthDef(
    name: "echo_testSynth",
    ugenGraphFunc: {
        var inSig, outL, outR;

        // Create the input signal - mono
        inSig = PlayBuf.ar(
            numChannels: 2,  // Changed back to mono
            bufnum: ~sound.bufnum,
            loop: 1
        );

        // Apply echo processing
        outL = ~echoproc.value(
            i_output: \on,
            i_delayIntType: \cubIntDelay,
            i_maxDelay: 1,
            i_echoProcDefFunc: { arg a_in; a_in; },
            a_input: inSig,
            a_delay: d,
            a_fbLevel: l
        );

        outR = outL;  // Same signal for both channels

        // Output the signal
        Out.ar(~c_AUDIO_L_BUS, ~c_AUDIO_ATTENUATION * outL);
        Out.ar(~c_AUDIO_R_BUS, ~c_AUDIO_ATTENUATION * outR);
    }
).add;
)

// GUI setup
(
w = Window.new("Echo GUI", Rect(200,200,255,100));
l = Slider.new(w,Rect(5,0,150,30));
~l_label = StaticText.new(w, Rect(5, 30, 150, 20)).string_("Feedback Level");

d = Slider.new(w,Rect(5,50,150,30));
~d_label = StaticText.new(w, Rect(5, 80, 150, 20)).string_("Delay Level");
c = CompositeView.new(w,Rect(20,35,100,60));
w.front;

// Add slider actions
l.action_({ |slider|
    ~testSynth.set(\a_fbLevel, slider.value);
});

d.action_({ |slider|
    ~testSynth.set(\a_delay, slider.value);
});
)

// Play and control functions
~testSynth = Synth("echo_testSynth");
~testSynth.free;

~dspServer.quit;