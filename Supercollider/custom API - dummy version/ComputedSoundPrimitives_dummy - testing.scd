/* Staas de Jong - Example SuperCollider code for the IATHMI course.
*/

// beforehand: ensure ComputedSoundPrimitives_dummy is compiled as part of your Extensions
//             & verify this on startup, via the Post window

// boot a synthesis/DSP server on localhost
Server.local.boot;

// set a global object variable to refer to the now-running server
~dspServer = Server.local;

// make sure it is the default server
Server.default = ~dspServer;



// sanity check: the server's node tree is still empty?
~dspServer.queryAllNodes;



// define some basic choices for live audio playback
~c_AUDIO_L_BUS       = 0;
~c_AUDIO_R_BUS       = ~c_AUDIO_L_BUS + 1;
~c_AUDIO_ATTENUATION = (0.75).linexp (0, 1, 1e-04, 1);

// fill a memory buffer with a prerecorded audio signal, read in from disk
~grainSrcBuf = Buffer.read (~dspServer, Platform.resourceDir +/+ "sounds/a11wlk01-44_1.aiff");
~grainSrcBuf.numChannels; // audio signal: number of channels ?
~grainSrcBuf.sampleRate;  // audio signal: sample rate ?
~grainSrcBuf.numFrames;   // audio signal: length, in samples ?
~grainSrcBuf.plot;        // audio signal: view it visually...

// compute the duration, in seconds, of the read-in audio signal
~grainSrcBuf_dur_s = ~grainSrcBuf.numFrames / ~grainSrcBuf.sampleRate;



// get an instance of the custom audio synthesis API,
// see "ComputedSoundPrimitives_dummy.sc"
~csp = ComputedSoundPrimitives_dummy.new;



// define a synthesis/DSP algorithm to test the API's Basic Grain Generator (bgg) primitive
(
  ~bgg_testSynthDef = SynthDef
  ( name: "bgg_testSynth",
    ugenGraphFunc: // the algorithm itself, built from unit generators & the bgg primitive:
    { arg bufPlayRate_arg   = 1.0,
          grainPlayRate_arg = 1.0;

      var grainSrcBufPos_s = LFSaw.ar
        ( freq:   (1.0 / ~grainSrcBuf_dur_s) * bufPlayRate_arg,
          iphase: 1.0,
          mul:    0.5,
          add:    0.5
        ) * ~grainSrcBuf_dur_s;

      var out_sig_l = ~csp.bgg
        ( \on,
          a_trig:          Impulse.ar (freq: 30.0),
          a_srcBufNum:     ~grainSrcBuf,
          a_srcBufPos:     grainSrcBufPos_s,
          a_grainDur:      0.1,
          a_grainAmp:      0.5,
          a_grainPlayRate: K2A.ar (grainPlayRate_arg)
        );

      var out_sig_r = out_sig_l;
      Out.ar (bus: ~c_AUDIO_L_BUS, channelsArray: ~c_AUDIO_ATTENUATION * out_sig_l);
      Out.ar (bus: ~c_AUDIO_R_BUS, channelsArray: ~c_AUDIO_ATTENUATION * out_sig_r);
    }
  );
)



// compile & run the synthesis/DSP algorithm (defined above) on the (default) server
~testSynth = ~bgg_testSynthDef.play;

// sanity check: the algorithm has appeared in the server's node tree?
~dspServer.queryAllNodes;

// start a digital oscilloscope
~dspServer.scope; // default: shows server's audio output channels 0 & 1
~dspServer.queryAllNodes;



// manually send updates to the arguments of the running synthesis/DSP algorithm
// here: to demonstrate live time stretching/compression...
~testSynth.set (\bufPlayRate_arg, 1.0);
~testSynth.set (\bufPlayRate_arg, 0.9);
~testSynth.set (\bufPlayRate_arg, 0.8);
~testSynth.set (\bufPlayRate_arg, 0.7);
~testSynth.set (\bufPlayRate_arg, 1.0);
~testSynth.set (\bufPlayRate_arg, 1.2);
~testSynth.set (\bufPlayRate_arg, 1.4);
~testSynth.set (\bufPlayRate_arg, 2.0);
~testSynth.set (\bufPlayRate_arg, 1.0);
~testSynth.set (\bufPlayRate_arg, 0.5);
~testSynth.set (\bufPlayRate_arg, 0.1);
~testSynth.set (\bufPlayRate_arg, 0.0);
~testSynth.set (\bufPlayRate_arg, 1.0);

// terminate the DSP algorithm
~testSynth.free;
~dspServer.queryAllNodes;



// compile and run the synthesis/DSP algorithm (defined above) on the server
~testSynth = ~bgg_testSynthDef.play;

// also have a *client-side algorithm*, which sends updates to the arguments of the
// running synthesis/DSP algorithm - here: to demonstrate live pitch shifting...
( {

    for (0, 10,
    { arg i;

      var grainPlayRate = 1.0 + (i / 10.0);

      //grainPlayRate.postln;
      ~testSynth.set (\grainPlayRate_arg, grainPlayRate);

      ~grainSrcBuf_dur_s.wait;
    });

    "For loop finished.\n".postln;

  }.fork; // run this code in a separate thread
)

// terminate the DSP algorithm
~testSynth.free;



// terminate the DSP server
~dspServer.quit;
