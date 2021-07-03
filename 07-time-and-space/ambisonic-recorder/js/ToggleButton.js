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

class ToggleButton {
  constructor(buttonEl, toggleOnCallback, toggleOffCallback) {
    this.element_ = buttonEl;
    this.state_ = false;
    this.toggleOnCallback_ = toggleOnCallback;
    this.toggleOffCallback_ = toggleOffCallback;
    this.initializeEventListener_();
  }

  initializeEventListener_() {
    this.element_.addEventListener('click', this.toggle.bind(this));
  }

  set(textContent, state) {
    this.element_.textContent = textContent;
    this.state_ = state;
  }

  reset() {
    this.state_ = false;
    this.toggleOffCallback_(this.element_);
  }

  toggle() {
    this.state_ = !this.state_;
    this.state_ ? this.toggleOnCallback_(this.element_)
                : this.toggleOffCallback_(this.element_);
  }
}

export default ToggleButton;
