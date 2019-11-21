/**
 * Copyright (C) 2019 Center for Computer Research in Music and Acoustics
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 **/

import ER from '../../lib/ExampleRunner.js';

const context = new AudioContext();

/**
 * Based on Fig. 10. FM circuit to produce dynamic spectra
 * from https://ccrma.stanford.edu/sites/default/files/user/jc/fm_synthesispaper-2.pdf
 * P3 = overall duration
 * P4 = overall amplitude
 * P5 = carrier frequency
 * P6 = modulator frequency
 * P7 = modulation index 1
 * P8 = modulation index 2
 */

/* Brass-like preset */
const p3 = .6;
const p4 = 1.0;
const p5 = 440;
const p6 = 440;
const p7 = 0;
const p8 = 5;
const egData = [[0, 0], [1, 1/6], [0.65, 1/3], [0.6, 5/6], [0, 1]];

/* Bell-like preset */
// const p3 = 15;
// const p4 = 1.0;
// const p5 = 200;
// const p6 = 280;
// const p7 = 0;
// const p8 = 10;
// // A crude approximation of an exponential decay curve.
// const egData = [
//   [Math.pow(0.001, 0), 0],
//   [Math.pow(0.001, 1/10), 1/10],
//   [Math.pow(0.001, 1/5), 1/5],
//   [Math.pow(0.001, 2/5), 2/5],
//   [Math.pow(0.001, 3/5), 3/5],
//   [Math.pow(0.001, 4/5), 4/5],
//   [Math.pow(0.001, 5/5), 5/5],
// ];


/**
 * FM synth implementation
 **/

const car = new OscillatorNode(context);
const eg1 = new ConstantSourceNode(context);
const amp = new GainNode(context);

const eg2 = new ConstantSourceNode(context);
const mod = new OscillatorNode(context);
const modAmp = new GainNode(context);

eg2.connect(modAmp.gain);
mod.connect(modAmp).connect(car.frequency);
eg1.connect(amp.gain);
car.connect(amp).connect(context.destination);

const dev1 = p7 * p6;
const dev2 = (p8 - p7) * p6;

car.frequency.value = p5;
mod.frequency.value = p6;
modAmp.gain.value = dev1;

// To shut off the carrier by default.
eg1.offset.value = 0;
amp.gain.value = 0;

eg1.start();
eg2.start();
mod.start();
car.start();

function startFMSynth() {
  const now = context.currentTime;
  egData.forEach((egEntry, index) => {
    let value = egEntry[0];
    const time = now + egEntry[1] * p3;
    if (index === 0) {
      eg1.offset.setValueAtTime(value * p4, time)
      eg2.offset.setValueAtTime(value * dev2, time)
    } else {
      eg1.offset.linearRampToValueAtTime(value * p4, time);
      eg2.offset.linearRampToValueAtTime(value * dev2, time);
    }
  });
}

ER.defineButton('button-start', startFMSynth, 'once');
ER.start();
