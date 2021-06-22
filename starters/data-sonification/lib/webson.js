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

/**
 * webson: web-based sonification helpers
 */

const ErrorMessages = {
  INVALID_ACTIVATION_CALLBACK:
    "[WebSon] displayActivationModal() needs a valid function."
};

class WebSon {
  constructor() {
    this._context = new AudioContext();
    this._context.suspend();
    this._activationCallback = null;
  }

  displayActivationModal(onActivationCallback) {
    if (typeof onActivationCallback === "function") {
      this._activationCallback = onActivationCallback;
    } else {
      throw Error(ErrorMessages.INVALID_ACTIVATION_CALLBACK);
    }
    const eModalOverlay = document.createElement("div");
    eModalOverlay.style.cssText =
      "display: flex; " +
      "align-items: center; justify-content: center;" +
      "z-index: 1000; position: fixed; " +
      "top: 0; left: 0; width: 100%; height: 100%; " +
      "color: #fff; background: rgba(0, 0, 0, 0.6);" +
      "font-family: serif; font-size: 1.6rem;";
    eModalOverlay.textContent = "Click to start";
    eModalOverlay.addEventListener("click", async () => {
      eModalOverlay.style.display = "none";
      this._context.resume();
      await this._activationCallback(this._context);
    });
    document.body.appendChild(eModalOverlay);
  }
}

export default new WebSon();
