'use strict';

const _COLLECTION = '../pho-doc/fragments';  // ..
const _BACKEND = 'backend.py';
const _PYTHON = 'python3';  // ..


const { PythonShell } = require('python-shell');
const path = require('path');


// Buttons

const buttonStateThing = (btn) => {
  // maybe just for goofing around

  const state = {};
  state.isWorking = false;

  const prevText = btn.innerText;

  const changeToNotWorking = () => {
    if (! state.isWorking ) {
      throw "already not working";
    }
    state.isWorking = false;
    btn.innerText = prevText;
    btn.classList.remove('is-danger');
  };

  const changeToWorking = () => {
    if (state.isWorking) {
      throw "already working";
    }
    state.isWorking = true;
    btn.innerText = 'Retrieving';
    btn.classList.add('is-danger');
  };

  return [changeToWorking, changeToNotWorking, state];
};


(btn => {
  const [changeToWorking, changeToNotWorking, state] = buttonStateThing(btn);

  btn.onclick = e => {
    if (state.isWorking) {
      return changeToNotWorking();
    }
    doClick();
  };

  const doClick = () => {
    changeToWorking();

    const onEntity = (entity) => {
      if (! state.isWorking) {
        return console.log("cancelled mid-call?");
      }
      changeToNotWorking()
      populateEntity(entity);
    };

    const args = [collPath];
    codec.requestJSON('retrieve_random_notecard', args).then(onEntity);
  };

})(document.getElementById('randomBtn'));


const onClickReferenceLink = ev => {

  const onEntity = (entity) => {
    console.log('wahoo worked');
    populateEntity(entity);
  };

  const iid = ev.target.innerText;
  console.log('go daddy '+iid);

  const args = [iid, collPath];
  codec.requestJSON('retrieve_notecard', args).then(onEntity);
  return false;
};


(btn => {
  const [changeToWorking, changeToNotWorking, state] = buttonStateThing(btn);

  btn.onclick = e => {
    if (state.isWorking) {
      return changeToNotWorking();
    }
    doClick();
  };

  const doClick = () => {
    changeToWorking();

    const onLines = (lines) => {
      if (! state.isWorking) {
        return console.log("cancelled mid-call?");
      }
      changeToNotWorking()
      console.log('wahoo done! here is lines:');
      let lineno = 0
      lines.forEach(line => {
        lineno += 1;
        console.log(`line ${lineno}: ${line}`);
      });
    };

    codec.requestLines('hello_to_pho', ['aa', 'bb']).then(onLines);
  };

})(document.getElementById('helloBtn'));


const populateEntity = ent => {

  wrf(parentField, ent.parent);
  wrf(previousField, ent.previous);
  wrf(nextField, ent.next);
  writeChildrenField(ent.children);

  identifierInput.value = ent.identifier || '';
  headingInput.value = ent.natural_key || ent.heading || '';
  datetimeInput.value = ent.document_datetime || '';
  bodyTextarea.value = ent.body || '';  // not innerText
};


const writeChildrenField = cx => {
  if (cx) {
    doWriteChildrenField(cx);
  } else {
    clearChildrenField();
  }
};


const doWriteChildrenField = cx => {
  const el = childrenField.children[1];
  const hacky = cx.map(s => {return `<a>${s}</a>`;}).join(', ');
  el.innerHTML = hacky;
  Array.from(el.children).forEach(wireReferenceForClicking);
  const style = childrenField.style;
  if ('none' === style.display) {
    style.display = 'flex';
  }
};


const clearChildrenField = () => {
  const style = childrenField.style;
  if ('none' !== style.display) {
    style.display = 'none';
  }
  const el = childrenField.children[1];
  el.innerHTML = '';
};


const wrf = (field, value) => {
  if (value) {
    writeReferenceField(field, value);
  } else {
    hideReferenceField(field);
  }
};


const writeReferenceField = (field, value) => {
  const style = field.style;
  anchorViaField(field).innerText = value;
  if ('none' === style.display) {
    style.display = 'flex';
  }
};


const hideReferenceField = (field) => {
  const style = field.style;
  if ('none' === style.display) {
    return;
  }
  style.display = 'none';
  anchorViaField(field).innerText = '222';  // ick/meh
};


const anchorViaField = field => {
  return field.children[1].children[0];  // not ok, but meh for now
};


const wireReferenceForClicking = a => {
  a.onclick = onClickReferenceLink;
};


const parentField = document.getElementById('parentField');
const previousField = document.getElementById('previousField');
const identifierInput = document.getElementById('identifierInput');
const headingInput = document.getElementById('headingInput');
const datetimeInput = document.getElementById('datetimeInput');
const bodyTextarea = document.getElementById('bodyTextarea');
const nextField = document.getElementById('nextField');
const childrenField = document.getElementById('childrenField');


wireReferenceForClicking(anchorViaField(parentField));
wireReferenceForClicking(anchorViaField(previousField));
wireReferenceForClicking(anchorViaField(nextField));


const codec = (() => {

  const exp = {};

  exp['requestJSON'] = (commandName, args) => {
    return requestJSON(buildShell(commandName, args || []));
  };

  exp['requestLines'] = (commandName, args) => {
    return requestLines(buildShell(commandName, args || []));
  };

  const requestJSON = (pyshell) => {
    return new Promise((resolve, reject) => {
      requestLines(pyshell).then(lines => {
        const bigString = lines.join('');
        console.log(`big string: ${bigString}`);
        resolve(JSON.parse(bigString));
      });
    });
  };

  const requestLines = (pyshell) => {

    return new Promise((resolve, reject) => {

      // State
      const stdouts = [];

      // pyshell.send('some user data')

      pyshell.on('message', (message) => {

        if (! message) {
          return reject("empty message");
        }

        const idx = message.indexOf(': ');

        if (-1 === idx) {
          return reject(`no header in message: ${message}`);
        }

        const type = message.slice(0, idx);

        if ('stderr' === type) {
          return console.log(message);  // or tail
        }

        if ('stdout' !== type) {
          return reject(`strange type: ${type}`);
        }

        const tail = message.slice(idx + 2);  // be careful
        // console.log(`receceived stdout payload: ${tail}`);
        stdouts.push(tail);
      });

      pyshell.end((err, code, signal) => {
        if (err) {
          return reject(err);
        }
        if (0 !== code) {
          return reject(`got exit code ${code} (${signal})`);
        }
        resolve(stdouts);
      });
    });
  };

  const buildShell = (commandName, args) => {
    const options = {args: [commandName, ...args], ...commonOptions};
    return new PythonShell(_BACKEND, options);
  };

  const commonOptions = {
    scriptPath: path.resolve(path.join(__dirname, '..', '..')),
    pythonPath: _PYTHON,
    pythonOptions: ['-u'],  // stdin, stdout & stderr unbuffered
    mode: 'text',
  };

  return exp;
})();


const collPath = path.resolve(path.join(__dirname, '..', '..', _COLLECTION));


/*
 * #history-A.2: spike codec and random button
 * #history-A.1: remove screen recording tutorial code
 * #born (from tutorial)
 */
