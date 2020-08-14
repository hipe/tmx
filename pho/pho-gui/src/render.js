'use strict';

const _COLLECTION = '../pho-doc/fragments';  // ..
const _BACKEND = 'backend.py';
const _PYTHON = 'python3';  // ..


const { PythonShell } = require('python-shell');
const path = require('path');


const formalFields = [
  {key: "parent", isRef: true, element: ()=>{return parentField;}},
  {key: "previous", isRef: true, element: ()=>{return previousField;}},
  {key: "identifier", editable: false, element: ()=>{return identifierInput;}},
  {key: "heading", element: ()=>{return headingInput;}},
  {key: "document_datetime", editable: false, element: ()=>{return datetimeInput;}},
  {key: "body", element: ()=>{return bodyTextarea;}},
  {key: "next", isRef: true, element: ()=>{return nextField;}},
  { key: "children",
    isRef: true,
    element: ()=>{return childrenField;},
    receive: (x)=>{writeChildrenField(x);}
  }
];  // [#882.M]


const o = (s) => { return document.getElementById(s); };


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
      receiveEntity(entity);
    };

    const args = [collPath];
    codec.requestJSON('retrieve_random_notecard', args).then(onEntity);
  };
})(o('randomBtn'));


const onClickReferenceLink = ev => {

  const onEntity = (entity) => {
    console.log('wahoo worked');
    receiveEntity(entity);
  };

  const iid = ev.target.innerText;
  console.log('go daddy '+iid);

  const args = [iid, collPath];
  codec.requestJSON('retrieve_notecard', args).then(onEntity);
  return false;
};


(() => {
  const closedLock = o('closedLock');
  const openLock = o('openLock');
  const editBtn = o('editBtn');
  const cancelBtn = o('cancelBtn');
  const submitBtn = o('submitBtn');

  editBtn.onclick = e => {
    if (globalState.isEditing) {  // strange
      console.log("STRANGE: already editing");
      return;
    }
    myChangeToEditing();
  };

  cancelBtn.onclick = e => {
    if (!globalState.isEditing) {  // strange
      console.log("STRANGE: cancel pressed when not editing");
      return;
    }
    myChangeToNotEditing();
  };

  submitBtn.onclick = e => {
    if (!globalState.isEditing) {  // strange
      console.log("STRANGE: submit pressed when not editing");
      return;
    }
    submit();
  };

  const myChangeToEditing = () => {
    if (!changeToEditing()) {
      return;
    }
    hide(closedLock);
    show(openLock);
    hide(editBtn);
    show(cancelBtn);
    show(submitBtn);
  };

  const myChangeToNotEditing = () => {
    show(closedLock);
    hide(openLock);
    show(editBtn);
    hide(cancelBtn);
    hide(submitBtn);
    changeToNotEditing();
  };
})();


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

})(o('helloBtn'));


/* ==== BEGIN submit */

const submit = () => {
  const ent = globalState.lastEntity;
  const args = [collPath];
  args.push(ent.identifier);
  const countBefore = args.length;

  formalFields.forEach((formal) => {
    if (!formalIsEditable(formal)) {
      return;
    }
    const existingValue = ent[formal.key];
    const requestedValue = requestedValueViaEditableFormal(formal);

    const existingIsSomething = isSomething(existingValue);
    const requestedIsSomething = isSomething(requestedValue);

    if (existingIsSomething) {
      if (requestedIsSomething) {
        if (existingValue === requestedValue) {
          /* hi. no change in value. do nothing. */
        } else {
          args.push('update_attribute', formal.key, requestedValue);
        }
      } else {
        args.push('delete_attribute', formal.key);
      }
    } else if (requestedIsSomething) {
      args.push('create_attribute', formal.key, requestedValue);
    } else {
      /* hi. it wasn't set before and it's not set now. do nothing. */
    }
  });

  if (countBefore === args.length) {
    console.log("OHAI: no change in form. not sumitting.");
    return;
  }

  const onEntity = (entity) => {
    if (globalState.isEditing) {
      // this is a somewhat more arbitrary UI behavior choice:
      // on successful submit, pop back out of edit mode
      changeToNotEditing();
    } else {
      console.log("OOPS: received ajax response after edit session");
    }
    receiveEntity(entity);
  };

  const onReject = (wat) => {
    console.log("go reject: " + wat);
  };

  codec.requestJSON('update_notecard', args).then(onEntity, onReject);
};

const requestedValueViaEditableFormal = (formal) => {
  const el = formal.element();
  if (formal.isRef) {
    const input = inputViaReferenceField(el);
    return input.value;
  }
  return el.value;
};

/* ==== END */


const changeToEditing = () => {

  if (globalState.isEditing) {
    throw("where?");
  }

  if (!globalState.lastEntity) {
    console.log("OOPS: no entity loaded yet so can't enter edit mode");
    return
  }

  globalState.isEditing = true;

  const ent = globalState.lastEntity;

  formalFields.forEach((formal) => {
    if (!formalIsEditable(formal)) {
      return;
    }

    const value = ent[formal.key];

    const el = formal.element()
    if (formal.isRef) {

      const span = spanViaReferenceField(el);
      if (!span) {
        console.log("SPAN NOT FOUND FOR " + formal.key);
        return;
      }

      const input = inputViaReferenceField(el);
      hide(span);
      if (!input) {
        console.log("INPUT NOT FOUND FOR " + formal.key);
        return;
      }

      input.value = value || '';  // #here1
      show(input);

      if (!value) {  // #here2
        showReferenceField(el);
      }
      return;
    }
    el.value = value || '';  // #here1
    el.removeAttribute('readonly');
  });
  return true;
};


const changeToNotEditing = () => {

  if (!globalState.isEditing) {
    throw("where?");
  }
  globalState.isEditing = false;

  const ent = globalState.lastEntity;

  formalFields.forEach((formal) => {
    if (!formalIsEditable(formal)) {
      return;
    }

    const value = ent[formal.key];

    const el = formal.element();

    if (formal.isRef) {
      if (!value) {  // #here2
        hideReferenceField(el);
      }

      const span = spanViaReferenceField(el);
      const input = inputViaReferenceField(el);
      hide(input);
      input.value = 'xxx';

      show(span);  // is there ever a reason to set value?
      return;
    }
    el.value = value || '';  // #here1
    el.setAttribute('readonly', 'readonly');
  });

};


const receiveEntity = ent => {
  globalState.lastEntity = ent;

  formalFields.forEach((formal) => {
    const value = ent[formal.key];
    const recv = formal.receive;
    if (recv) {
      recv(value);
      return;
    }
    const el = formal.element()
    if (formal.isRef) {
      writeReferenceField(el, value);
      return;
    }
    el.value = value || '';  // #here1
  });
};


const writeChildrenField = cx => {
  if (cx) {
    doWriteChildrenField(cx);
  } else {
    clearChildrenField();
  }
};


const doWriteChildrenField = cx => {
  const el = spanViaReferenceField(childrenField);
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
  spanViaReferenceField(childrenField).innerHTML = '';
};


const writeReferenceField = (field, value) => {
  if (value) {  // #here2
    doWriteReferenceField(field, value);
  } else {
    hideReferenceField(field);
  }
};


const doWriteReferenceField = (field, value) => {
  anchorViaReferenceField(field).innerText = value;
  showReferenceField(field);
}


const showReferenceField = (field) => {
  const style = field.style;
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
  spanViaReferenceField(field).innerText = '222';  // ick/meh
};


// == BEGIN not okay. but meh for now. #open [#882.L]

const anchorViaReferenceField = field => {
  const span = spanViaReferenceField(field)
  const anchor = span.children[0];
  return anchor;
};

const inputViaReferenceField = field => {
  const fieldBodyDiv = field.children[1];
  const input = fieldBodyDiv.children[1];
  return input;
};

const spanViaReferenceField = field => {
  const fieldBodyDiv = field.children[1];
  const span = fieldBodyDiv.children[0];
  return span;
};

// == END


const wireReferenceForClicking = a => {
  a.onclick = onClickReferenceLink;
};


const hide = (btn) => {
  btn.classList.add('is-hidden');
};


const show = (btn) => {
  btn.classList.remove('is-hidden');
};


const formalIsEditable = (formal) => {
  const yes = formal.editable;
  if (undefined === yes) {
    return true;
  }
  return yes;
}

const isSomething = (mixed) => {
  const typ = typeof(mixed);
  switch (typ) {
    case 'string':
      return ('' !== mixed);  // nonzero length but "blank" is something f.n.
    case 'undefined':
      return false;
    case 'object':
      return (null !== mixed);
    default:
      console.log(`STRANGE: why do we have this type: "${typ}"`);
      return true;
  }
};

const parentField = o('parentField');
const previousField = o('previousField');
const identifierInput = o('identifierInput');
const headingInput = o('headingInput');
const datetimeInput = o('datetimeInput');
const bodyTextarea = o('bodyTextarea');
const nextField = o('nextField');
const childrenField = o('childrenField');


wireReferenceForClicking(anchorViaReferenceField(parentField));
wireReferenceForClicking(anchorViaReferenceField(previousField));
wireReferenceForClicking(anchorViaReferenceField(nextField));


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
          console.log("FOR NOW not throwing, might be UI error: " +err);
          return;
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

const globalState = {isEditing: false};
document.GLOBAL_STATE = globalState;  // just for console debugging

/*
 * #history-A.2: spike codec and random button
 * #history-A.1: remove screen recording tutorial code
 * #born (from tutorial)
 */
