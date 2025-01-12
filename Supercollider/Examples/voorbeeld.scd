/_ supercoollider voorbeeldcode
_/

// tekst output gaat via het Post window
"Hello World!".postln;

// meeder regels uitvoeren gaat met ronde haakjes
(
"Hello".postln;
"World".postln;
)

// je kan de documentatie van ieder standaard object opvragen
// via het help menu / met cursorplaatsing en toetscombinatie:
Server

// een DSP-server booten kan gewoon localohst:
Server.local.boot;

// globale variabele beginnen met een tilde:
~dspServer = Server.local;

// op sommige afkortingen in SuperCollider te kunnen gebruiken
// is het belangrijk dat jouw server de "default server"is

Server.default = ~dspServer;

// je dsp-code krijgt op de server een plek in de "node-tree"
// die zou nog leeg moeten zijn:

~dspServer.queryAllNodes;

// output van blocks gaat naar je DACs zal gaan via de laagst genummerde bussen:
~c_AUDIO_L_BUS = 0;
~c_AUDIO_R_BUS = ~c_AUDIO_L_BUS + 1;

//bepaal eem laag getal om alle sample-waarden mee te vermenigvuldigen
// voordat deze via de bussen je oren gaat:

~c_AUDIO_ATTENUATION = 0.1;

// we gebruiken hierbij liever exponetieel schalen (
~c_AUDIO_ATTENUATION = (0.75).linexp (0, 1, 1e-04, 1);

// basis-objecten om DSP mee te bouwen heten Unit generators (UGens)
// bijvoorbeeld: "SinOsc", "Out", enz.
// met elkaar gecombineerd via hun I/O vormen ze: Unit Generator Graphs
// eenmaal compleet gaat dit in een Synth Definition (SynthDef)

(
~testSynthDef = SynthDef
(
name: "testSynth",
ugenGraphFunc:
{
arg freq_hz_arg = 220.0;

    	var out_sig_l = SinOsc.ar (freq: freq_hz_arg);
    	var out_sig_r = out_sig_l;

    	Out.ar (~c_AUDIO_L_BUS, ~c_AUDIO_ATTENUATION * out_sig_l);
    	Out.ar (~c_AUDIO_R_BUS, ~c_AUDIO_ATTENUATION * out_sig_r);
    }

);
)

// SyntDef-code kan naar de default server gestuurd worden
// om daar te worden gecompileerd en gestart:

~testSynth = ~testSynthDef.play;
~dspServer.scope;

~testSynth.set (\freq_hz_arg, 0);

~testSynth.free;
~dspServer.queryAllNodes;
~dspServer.quit;
