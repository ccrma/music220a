/**
 * Copyright (C) 2021 Center for Computer Research in Music and Acoustics
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

/* global currentTime sampleRate */

const RQ_FRAMES = 128;
const RECORDING_BUFFER_LENGTH = 1;

class StereoRecorderProcessor extends AudioWorkletProcessor {
  constructor() {
    super();
    this.bufferSize_ =
        Math.floor(sampleRate * RECORDING_BUFFER_LENGTH / RQ_FRAMES) * 
        RQ_FRAMES;
    this.initializeBuffer();
  }

  initializeBuffer() {
    this.recordingBuffer_ = [
      new Float32Array(this.bufferSize_),
      new Float32Array(this.bufferSize_)
    ];
    this.frameCounter_ = 0;
  }

  process(inputs, outputs, parameters) {
    // 1 input with 2 channels.
    if (inputs.length === 1 && inputs[0].length === 2) {
      const channels = inputs[0];
      for (let index = 0; index < channels.length; ++index) {
        this.recordingBuffer_[index].set(channels[index], this.frameCounter_);
        outputs[0][index].set(inputs[0][index]);
      }
      this.frameCounter_ += channels[0].length;
      if (this.frameCounter_ >= this.bufferSize_) {
        this.port.postMessage({
          timestamp: currentTime,
          bufferLeft: this.recordingBuffer_[0],
          bufferRight: this.recordingBuffer_[1]
        }, [
          this.recordingBuffer_[0].buffer,
          this.recordingBuffer_[1].buffer
        ]);
        this.initializeBuffer();
      }
    }

    return true;
  }
};

registerProcessor('stereo-recorder-processor', StereoRecorderProcessor);
