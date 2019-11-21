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
import Util from '../../lib/Util.js';

const context = new AudioContext();
const osc = new OscillatorNode(context, {type: 'triangle'});
const amp = new GainNode(context, {gain: 0.0});
const master = new GainNode(context, {gain: 0.0});
osc.connect(amp).connect(master).connect(context.destination);
osc.start();

const Color = {
  Black: '#000000',
  White: '#FFFFFF',
  Highlight: '#448AFF',
};

const setup = () => {
  // A toggle button
  const toggle = document.querySelector('#button-toggle');
  toggle.state = false;
  toggle.addEventListener('mousedown', () => {
    // If the context is blocked by the autoplay policy, unlock it.
    if (context.state !== 'running')
      context.resume();

    toggle.state = !toggle.state;
    if (toggle.state) {
      toggle.style.backgroundColor = Color.Highlight;
      master.gain.value = 1.0;
    } else {
      toggle.style.backgroundColor = Color.White;
      master.gain.value = 0.0;
    }
  });
  
  window.addEventListener('keydown', (event) => {
    osc.frequency.value = Util.mtof(event.keyCode);
    amp.gain.setValueAtTime(0.0, context.currentTime);
    amp.gain.linearRampToValueAtTime(1.0, context.currentTime + 0.01);
    amp.gain.setTargetAtTime(0.0, context.currentTime + 0.01, 0.01);
  });
};

ER.start(setup);
