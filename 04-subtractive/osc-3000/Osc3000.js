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

class Osc3000 {
  constructor(context) {
    // Creates some states and builds an audio graph.
    this.fundamental = 220;
    this.volume = 0.0;

    this.osc = new OscillatorNode(
        context, {frequency: this.fundamental});
    this.amp = new GainNode(
        context, {gain: this.volume});
    this.osc.connect(this.amp);
    this.amp.connect(context.destination);
    this.osc.start();
  }

  playBeep(frequency, volume, when) {
    // Sets frequency, and trigger parameter automations.
    this.osc.frequency.setValueAtTime(frequency, when);
    this.amp.gain.setValueAtTime(volume, when);
    this.amp.gain.linearRampToValueAtTime(0.0, when + 0.5);
  }

  stop() {
    // Stops source(s).
    this.osc.stop();
    this.osc = null;
  }
}

export default Osc3000;
