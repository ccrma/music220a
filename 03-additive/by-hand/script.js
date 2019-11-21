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
const master = new GainNode(context);
master.connect(context.destination);

// The fundamental frequency.
const fundamental = 300;

function addUp() {
  const osc1 = new OscillatorNode(context, {frequency: fundamental});
  const osc2 = new OscillatorNode(context, {frequency: fundamental * 2});
  const osc3 = new OscillatorNode(context, {frequency: fundamental * 3});
  const osc4 = new OscillatorNode(context, {frequency: fundamental * 4});
  const osc5 = new OscillatorNode(context, {frequency: fundamental * 5});
  const osc6 = new OscillatorNode(context, {frequency: fundamental * 6});
  const osc7 = new OscillatorNode(context, {frequency: fundamental * 7});
  const osc8 = new OscillatorNode(context, {frequency: fundamental * 8});
  
  // The amplitude of n-th partial = 1 / n
  // This creates 'sawtooth' waveform. Sort of. 
  const amp1 = new GainNode(context, {gain: 1.0});
  const amp2 = new GainNode(context, {gain: 1.0 / 2});
  const amp3 = new GainNode(context, {gain: 1.0 / 3});
  const amp4 = new GainNode(context, {gain: 1.0 / 4});
  const amp5 = new GainNode(context, {gain: 1.0 / 5});
  const amp6 = new GainNode(context, {gain: 1.0 / 6});
  const amp7 = new GainNode(context, {gain: 1.0 / 7});
  const amp8 = new GainNode(context, {gain: 1.0 / 8});
  
  osc1.connect(amp1).connect(master);
  osc2.connect(amp2).connect(master);
  osc3.connect(amp3).connect(master);
  osc4.connect(amp4).connect(master);
  osc5.connect(amp5).connect(master);
  osc6.connect(amp6).connect(master);
  osc7.connect(amp7).connect(master);
  osc8.connect(amp8).connect(master);
  
  const now = context.currentTime;
  const later = now + 4.0;
        
  osc1.start(now);
  osc1.stop(later);
  osc2.start(now);
  osc2.stop(later);
  osc3.start(now);
  osc3.stop(later);
  osc4.start(now);
  osc4.stop(later);
  osc5.start(now);
  osc5.stop(later);
  osc6.start(now);
  osc6.stop(later);
  osc7.start(now);
  osc7.stop(later);
  osc8.start(now);
  osc8.stop(later);
  
  // It might be loud, so let's be careful.
  master.gain.value = 1.0 / 8;
}

ER.defineButton('button-start', addUp, 'once');
ER.start();
