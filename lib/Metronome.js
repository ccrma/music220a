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

/**
 * The class `Metronome` can be used to drive the trigger function. With
 * given BPM and an AudioContext, the metronome instance can generate a value
 * stream that runs on a specified tempo (i.e. beat per minute).
 *
 * @class
 */
class Metronome {
  /**
   * @constructor
   * @param {BaseAudioContext} context The associated BaseAudioContext
   */
  constructor(context) {
    this._context = context;
    this._state = 'stopped';

    this._timerId = null;
    this._counter = 0;
    this.onbeat = null;
    this._boundCallback = this._callback.bind(this);

    this.setBPM(120);
  }

  /**
   * @private
   */
  _callback() {
    const pNow = performance.now();
    const untilNextScan = (this._prevTimestamp + 2 * this._scanRage) - pNow;
    this._prevTimestamp = pNow;

    const now = this._context.currentTime;
    if (this._nextBeat - now < this._scanRange) {
      if (this.onbeat) {
        this.onbeat(this._nextBeat, this._interval, this._counter);
      }
      this._nextBeat += this._interval;
      this._counter++;
    }

    this._timerId = setTimeout(this._boundCallback, untilNextScan * 1000);
  }

  /**
   * Sets BPM for the metronome.
   * @param {Number} bpm Beat per minute
   */
  setBPM(bpm) {
    this._bpm = bpm;
    this._interval = 60 / this._bpm;
    this._scanRange = this._interval;
  }

  /**
   * Resets the beat counter to zero.
   */
  resetCounter() {
    this._counter = 0;
  }

  /**
   * Starts the metronome.
   */
  start() {
    this._context.resume();
    if (this._state === 'stopped') {
      this._state = 'running';
      this._prevTimestamp = performance.now() - this._scanRange;
      this._nextBeat = this._context.currentTime + this._interval;
      this._callback();
    }
  }

  /**
   * Stops the metronome.
   */
  stop() {
    if (this._state === 'running') {
      clearTimeout(this._timerId);
      this._state = 'stopped';
    }
  }
}

export default Metronome;
