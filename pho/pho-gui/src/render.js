'use strict';

// Buttons
const randomBtn = document.getElementById('randomBtn');

(btn => {

  // temporary state hack, just for dumb demo
  let isOn = false;
  let prevText = null;

  btn.onclick = e =>  {
    if (isOn) {
      isOn = false;
      btn.classList.remove('is-danger');
      btn.innerText = prevText;
      return;
    }
    isOn = true;
    btn.classList.add('is-danger');
    prevText = btn.innerText;
    btn.innerText = 'Retrieving';
};
})(randomBtn);

/*
 * #history-A.1: remove screen recording tutorial code
 * #born (from tutorial)
 */
