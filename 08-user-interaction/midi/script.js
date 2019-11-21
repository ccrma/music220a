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

let logDiv = null;
const appendLog = (message) => {
  if (!logDiv)
    return;

  const newLine = document.createElement('p');
  newLine.textContent = `${message.type} ${message.value1} ${message.value2}`;
  logDiv.appendChild(newLine);
  if (logDiv.childNodes.length > 20)
    logDiv.removeChild(logDiv.childNodes[0]);
};

const handleMIDIMessage = (event) => {
  const message = event.data;
  let type = null;
  switch (message[0] >> 4) {
    case 8:
      type = 'noteoff';
      break;
    case 9:
      type = 'noteon';
      break;
    case 11:
      type = 'controlchange';
      break;
  }
  
  appendLog({
    type: type,
    value1: message[1],
    value2: message[2],
  });
};

const setup = async () => {
  logDiv = document.querySelector('#ui-log');
  
  // Connect all the MIDI input devices to |handleMIDIMessage| callback.
  const midiAccess = await navigator.requestMIDIAccess();
  midiAccess.inputs.forEach((input) => {
    input.onmidimessage = handleMIDIMessage;
  });
};

ER.start(setup);
