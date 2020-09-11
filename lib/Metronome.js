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

const DEBUG_MODE = false;

// Number of ticks per second. e.g. the tick factor of 25 means that 1000ms has
// 25 ticks in it, thus 1 tick is 40ms.
const TICKS_PER_SEC = 25;

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
   * @param {Nunmber} [beatPerMinute=120] BPM
   */
  constructor(context, beatPerMinute) {
    this._context = context;

    this._state = 'stopped';

    this._beatPerMinute = beatPerMinute || 120;
    this._beatCounter = 0;
    
    // In seconds. For the AudioContext time.
    this._interval = 60 / this._beatPerMinute;
    this._nextBeat = null;
    this._lastBeatScheduled = null;
    
    // In MS. Based on performance.now().
    this._tick = 1000 / TICKS_PER_SEC;
    this._prevTick = null;

    this._timerIds = [];
    this._boundCallback = this._callback.bind(this);
    
    // In MS. For debugging and timer quality.
    this._metric = {
      prev_ts: 0,
      ist_jitter: 0,
      avg_jitter: 0,
    };

    this.onbeat = null;
  }
  
  /**
   * @private
   */
  _callback() {
    if (DEBUG_MODE) {
      console.assert(this._state === 'stopped' || this._state === 'running');
    }
    
    if (this._state === 'stopped') {
      clearTimeout(this._timerId);
      return;
    }

    const now = performance.now();
    const untilNextTick = this._tick - (now % this._tick);
  
    this._metric.ist_jitter =
        Math.abs(this._tick - (now - this._metric.prev_ts));
    this._metric.avg_jitter = this._metric.avg_jitter * 0.75 +
                              this._metric.ist_jitter * 0.25;
    this._metric.prev_ts = now;

    const currentTime = this._context.currentTime;
    const nextBeat = currentTime - (currentTime % this._interval) + this._interval;
    if (nextBeat - currentTime < this._tick / 1000) {
      if (nextBeat !== this._lastBeatScheduled) {
        if (this.onbeat)
          this.onbeat(nextBeat, this._interval, this._beatCounter);
        this._beatCounter++;
        this._lastBeatScheduled = nextBeat;
      }
    }
    
    if (this._timerId)
      clearTimeout(this._timerId);
    this._timerId = setTimeout(this._boundCallback, untilNextTick);
    
    if (DEBUG_MODE) {
      console.log(`AVG JITTER=${this._metric.avg_jitter.toFixed(4)}ms`);
    }
  }

  /**
   * Sets BPM for the metronome.
   * @param {Number} [beatPerMinute] BPM
   */
  setBPM(beatPerMinute) {
    this._beatPerMinute = beatPerMinute;
    this._interval = 60 / this._beatPerMinute;
  }

  /**
   * Resets the beat counter to zero.
   */
  resetCounter() {
    this._beatCounter = 0;
  }

  /**
   * Starts the metronome.
   */
  start() {
    if (this._state === 'running')
      return;

    this._context.resume();
    this._state = 'running';
    this._callback();
  }

  /**
   * Stops the metronome.
   */
  stop() {
    if (this._state === 'stopped')
      return;
    
    this._state = 'stopped';
    this._callback();
  }
}

export default Metronome;
