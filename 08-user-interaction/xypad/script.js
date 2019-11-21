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

const Color = {
  Black: '#000000',
  White: '#FFFFFF',
  Highlight: '#448AFF',
};

const context = new AudioContext();
const osc = new OscillatorNode(context, {type: 'sawtooth'});
const biquad = new BiquadFilterNode(context);
const amp = new GainNode(context);
osc.connect(biquad).connect(amp).connect(context.destination);
osc.start();
amp.gain.value = 0;

let toggleState = false;
let canvas = null;
let context2D = null;
let taskId = null;
let userX = null;
let userY = null;

const onMouseMove = (event) => {
  if (!toggleState)
    return;

  const rect = event.target.getBoundingClientRect();
  userX = event.clientX - rect.left;
  userY = event.clientY - rect.top;
  
  // Maps (x, y) coordinate to the frequency of the oscillator and filter.
  const frequency = (userX / canvas.width) * 880 + 110;
  const cutoff = (1 - userY / canvas.height) * 3520 + 440;

  const later = context.currentTime + 0.04;
  osc.frequency.exponentialRampToValueAtTime(frequency, later);
  biquad.frequency.exponentialRampToValueAtTime(cutoff, later);
};

const render = () => {
  context2D.clearRect(0, 0, canvas.width, canvas.height);
  context2D.fillRect(userX - 5, userY - 5, 10, 10);
  taskId = requestAnimationFrame(render);
};

const setup = () => {
  // 2D rendering context
  canvas = document.getElementById('xy-pad');
  context2D = canvas.getContext('2d');
  canvas.addEventListener('mousemove', onMouseMove);

  // toggle button
  const toggle = document.querySelector('#button-toggle');
  toggle.textContent = 'TOGGLE';
  toggle.addEventListener('click', () => {
    toggleState = !toggleState;
    if (toggleState) {
      toggle.style.color = Color.White;
      toggle.style.backgroundColor = Color.Highlight;
      amp.gain.linearRampToValueAtTime(0.75, context.currentTime + 0.04);
      render();
    } else {
      toggle.style.color = Color.Black;
      toggle.style.backgroundColor = Color.White;
      amp.gain.setTargetAtTime(0.0, context.currentTime, 0.01);
      cancelAnimationFrame(taskId);
      context2D.clearRect(0, 0, canvas.width, canvas.height);
    }
  });
};

ER.start(setup);
