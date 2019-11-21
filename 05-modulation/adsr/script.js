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

const context = new AudioContext();

const osc = new OscillatorNode(context);
const amp = new GainNode(context);

osc.connect(amp).connect(context.destination);
osc.start();

osc.type = 'triangle';
amp.gain.value = 0.0;

let attack = 0.25;
let decay = 0.5;
let sustain = 0.6;
let release = 1.0;
let playing = false;

const timeConstantFactor = Math.log(1 / 0.001);

const buttonElement = document.querySelector('#button-noteon');

function noteOn() {
  if (playing)
    return;
  playing = true;
  buttonElement.textContent = 'NOTE OFF';
  const now = context.currentTime;
  amp.gain.setValueAtTime(0.0, now);
  amp.gain.linearRampToValueAtTime(1.0, now + attack);
  amp.gain.linearRampToValueAtTime(sustain, now + attack + decay);
}

function noteOff() {
  if (!playing)
    return;
  const now = context.currentTime;
  amp.gain.cancelAndHoldAtTime(now);
  amp.gain.setTargetAtTime(0.0, now, release / timeConstantFactor);
  buttonElement.textContent = 'NOTE ON';
  playing = false;
}

buttonElement.addEventListener('mousedown', noteOn);
buttonElement.addEventListener('mouseup', noteOff);
