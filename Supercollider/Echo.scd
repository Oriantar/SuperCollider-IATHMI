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

// Initialize global variables
~synthRunning = false;
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
    ugenGraphFunc: { |feedback = 0.1, delayTime = 0.5|
        var inSig, outL, outR;

        // Create the input signal - mono
        inSig = PlayBuf.ar(
            numChannels: 2,
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
            a_delay: delayTime,
            a_fbLevel: feedback
        );

        outR = outL;

        // Output the signal
        Out.ar(~c_AUDIO_L_BUS, ~c_AUDIO_ATTENUATION * outL);
        Out.ar(~c_AUDIO_R_BUS, ~c_AUDIO_ATTENUATION * outR);
    }
).add;
)

// Simple GUI setup
(
// Create window
w = Window("Echo Controls", Rect(200, 200, 300, 150));

// Add feedback level slider
~l_label = StaticText(w, Rect(10, 10, 100, 20))
    .string_("Echo Intensity");
l = Slider(w, Rect(10, 30, 280, 20))
    .value_(0.1)
    .action_({ |slider|
        if(~synthRunning, {
            ~testSynth.set(\feedback, slider.value);
            "Feedback set to: ".post; slider.value.postln;
        });
    });

// Add delay time slider
~d_label = StaticText(w, Rect(10, 60, 100, 20))
    .string_("Echo Speed");
d = Slider(w, Rect(10, 80, 280, 20))
    .value_(0.5)
    .action_({ |slider|
        if(~synthRunning, {
            ~testSynth.set(\delayTime, slider.value);
            "Delay time set to: ".post; slider.value.postln;
        });
    });

// Create play button
~playButton = Button(w, Rect(10, 110, 135, 30))
    .states_([
        ["Play", Color.black, Color.green(0.7)],
        ["Playing", Color.white, Color.green(0.9)]
    ])
    .action_({ |button|
        if(button.value == 1, {
            ~testSynth.free;  // Free any existing synth first
            ~testSynth = Synth("echo_testSynth", [
                \feedback, l.value,
                \delayTime, d.value
            ]);
            ~synthRunning = true;
        }, {
            ~testSynth.free;
            ~synthRunning = false;
        });
    });

// Create stop button
Button(w, Rect(155, 110, 135, 30))
    .states_([["Stop", Color.white, Color.red(0.7)]])
    .action_({
        ~testSynth.free;
        ~synthRunning = false;
        ~playButton.value = 0;
    });

w.front;
)