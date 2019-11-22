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
lfo.connect(depth).connect(amp.gain);

lfo.frequency.value = 1;

// The output of LFO is scaled to -0.5 ~ 0.5 and
// the main amplifier's intrinsic value is 0.5. (1.0 - LFO's depth)
// This will render the computed ampitude to 0 ~ 1.0.
// Note that depth's gain value cannot go beyond 0.5.
depth.gain.value = 0.5;
amp.gain.value = 1.0 - depth.gain.value;

const startTremolo = () => {
  osc.start();
  lfo.start();
};

ER.defineButton('button-start', startTremolo, 'once');
ER.start();
