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

    const args = [buildCollectionPath()];
    codec.requestJSON('retrieve_random_entity', args).then(onEntity);
  };

})(document.getElementById('randomBtn'));


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
  parentInput.value = ent.parent || '';
  previousInput.value = ent.previous || '';
  identifierInput.value = ent.identifier || '';
  headingInput.value = ent.natural_key || ent.heading || '';
  datetimeInput.value = ent.document_datetime || '';
  bodyTextarea.value = ent.body || '';  // not innerText
  nextInput.value = ent.next || '';

  // one day we'll know enough to make this pretty
  const cx = ent.children;
  const sCx = cx ? cx.join(', ') : '';
  children_TEMP_input.value = sCx;
};


const parentInput = document.getElementById('parentInput');
const previousInput = document.getElementById('previousInput');
const identifierInput = document.getElementById('identifierInput');
const headingInput = document.getElementById('headingInput');
const datetimeInput = document.getElementById('datetimeInput');
const bodyTextarea = document.getElementById('bodyTextarea');
const nextInput = document.getElementById('nextInput');
const children_TEMP_input = document.getElementById('children_TEMP_input');


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


const buildCollectionPath = () => {
  return path.resolve(path.join(__dirname, '..', '..', _COLLECTION));
};


/*
 * #history-A.2: spike codec and random button
 * #history-A.1: remove screen recording tutorial code
 * #born (from tutorial)
 */
