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

const lfo = new OscillatorNode(context);
const depth = new GainNode(context);
const osc = new OscillatorNode(context);
const amp = new GainNode(context);

osc.connect(amp).connect(context.destination);
lfo.connect(depth).connect(osc.frequency);

lfo.frequency.value = 5;

// Because the modulation range will be -200 ~ 200,
// the target oscillator's frequency will be modulated
// to 200Hz(400-200) ~ 600Hz(400+200).
depth.gain.value = 200; 
osc.frequency.value = 400;

function startVibrato() {
  osc.start();
  lfo.start();
}

ER.defineButton('button-start', startVibrato, 'once');
ER.start();
