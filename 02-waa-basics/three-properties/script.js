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

function playNote(freq, amp, timbre) {
  const osc = new OscillatorNode(context);
  const gain = new GainNode(context);
  osc.frequency.value = freq;
  osc.type = timbre || 'sine';
  gain.gain.value = amp;
  osc.connect(gain).connect(context.destination);
  osc.start();
  osc.stop(context.currentTime + 1);
}

ER.defineButton('freq1', () => playNote(60, 0.5));
ER.defineButton('freq2', () => playNote(750, 0.5));
ER.defineButton('freq3', () => playNote(2500, 0.5));
ER.defineButton('amp1', () => playNote(440, 0.1));
ER.defineButton('amp2', () => playNote(440, 0.4));
ER.defineButton('amp3', () => playNote(440, 0.75));
ER.defineButton('timbre1', () => playNote(440, 0.5));
ER.defineButton('timbre2', () => playNote(440, 0.5, 'square'));
ER.defineButton('timbre3', () => playNote(440, 0.5, 'sawtooth'));
ER.start();