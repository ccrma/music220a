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
