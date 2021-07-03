/**
 * @class StereoRecorderNode
 */
class StereoRecorderNode extends AudioWorkletNode {
  constructor(context) {
    super(context, 'stereo-recorder-processor', {
      // This will force the incoming stream to be up/down-mixed to stereo.
      channelCount: 2,
      channelCountMode: 'explicit'
    });

    this.stereoBufferQueue_ = [];
    this.totalRecordedFrameSize_ = 0;
    this.isRecording_ = false;
  }

  _onProcessorEvent(processorEvent) {
    if (!this.isRecording_)
      return;

    console.assert(processorEvent.data.bufferLeft.length > 0 &&
                   processorEvent.data.bufferRight.length > 0);

    this.stereoBufferQueue_.push([processorEvent.data.bufferLeft,
                                  processorEvent.data.bufferRight]);
    this.totalRecordedFrameSize_ += processorEvent.data.bufferLeft.length;
  }

  start() {
    this.isRecording_ = true;
    this.port.onmessage = this._onProcessorEvent.bind(this);
  }

  stop() {
    this.isRecording_ = false;
    this.port.onmessage = null;
  }

  reset() {
    if (this.isRecording_)
      return;
    
    this.stereoBufferQueue_ = [];
    this.totalRecordedFrameSize_ = 0;
    this.port.onmessage = null;
  }

  getRecordedBuffer() {
    if (this.isRecording_)
      return null;

    // TODO: Consider using a worker for merging arrays.
    const recordedBuffer = [
      new Float32Array(this.totalRecordedFrameSize_),
      new Float32Array(this.totalRecordedFrameSize_)
    ];
    let frameCounter = 0;
    for (let index = 0; index < this.stereoBufferQueue_.length; ++index) {
      recordedBuffer[0].set(this.stereoBufferQueue_[index][0], frameCounter);
      recordedBuffer[1].set(this.stereoBufferQueue_[index][1], frameCounter);
      frameCounter += this.stereoBufferQueue_[index][0].length;
    }

    return recordedBuffer;
  }
}

export default StereoRecorderNode;
