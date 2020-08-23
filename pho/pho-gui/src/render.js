'use strict';

const _COLLECTION = '../pho-doc/fragments';  // ..
const _BACKEND = 'backend.py';
const _PYTHON = 'python3';  // ..


const { PythonShell } = require('python-shell');


// ===== Fields =====

const defineMainFormFields = () => {
  // experimental formal fields definitions [#882.M]

  const exports = {};

  exports.fields = [
  {key: "parent", isRef: true, element: ()=>{return parentField;}},
  {key: "previous", isRef: true, element: ()=>{return previousField;}},
  {key: "identifier", editable: false, element: ()=>{return identifierInput;}},
  {key: "heading", element: ()=>{return headingInput;}},
  {key: "document_datetime", editable: false, element: ()=>{return datetimeInput;}},
  {key: "body", element: ()=>{return bodyTextarea;}},
  {key: "next", isRef: true, element: ()=>{return nextField;}},
  {key: "children", customExtend: fld => {extendChildrenField(fld, childrenField);}},
  ];

  const o = getElementById;
  const parentField = o('parentField');
  const previousField = o('previousField');
  const identifierInput = o('identifierInput');
  const headingInput = o('headingInput');
  const datetimeInput = o('datetimeInput');
  const bodyTextarea = o('bodyTextarea');
  const nextField = o('nextField');
  const childrenField = o('childrenField');

  exports.fields.forEach(field => {
    extendField(field);
  });

  return exports;
};


const extendField = field => {

  const cust = field.customExtend;
  if (cust) { return cust(field); }

  field.isEditable = () => { return isEditable; }

  const yn = field.editable;
  const isEditable = (undefined === yn) ? true : yn;

  field.encodeValue = s => {return s};

  if (isEditable) {
    if (field.isRef) {
      extendReferenceField(field);
    } else {
      extendCommonField(field);
    }
  } else {
    extendPermanantlyReadOnlyField(field);
  }
};


const extendChildrenField = (field, childrenField) => {

  field.isEditable = () => { return true; };

  field.ensureEditModeAnd = value => {
    if ('edit' !== mode()) { changeToEditMode(); }
    receiveValue(value);
  };

  field.ensureViewModeAnd = value => {
    if ('view' !== mode()) { changeToViewMode(); }
    receiveValue(value);
  };

  field.fieldValue = () => { return input.value; };

  field.encodeValue = arr => {
    if (!(arr && arr.length)) { return ''; }
    return arr.join(', ');
  }

  const receiveValue = value => {
    if (!(value && value.length)) { return receiveTheEmptyValue(); }

    const yikesHTML = value.map(s => {return `<a>${s}</a>`;}).join(', ');
    const yikesText = value.join(', ');

    span.innerHTML = yikesHTML;
    Array.from(span.children).forEach(a => {a.onclick = onClickReferenceLink;});

    input.value = yikesText;

    if (! wholeFieldIsVisible()) { makeWholeFieldVisible(); }
  };

  const receiveTheEmptyValue = () => {
    if ('view' == mode() && wholeFieldIsVisible()) {makeWholeFieldInvisible();}
    span.innerHTML = '';
    input.value = '';
    if ('edit' == mode() && ! wholeFieldIsVisible()) {makeWholeFieldVisible();}
  };

  const [makeWholeFieldInvisible, makeWholeFieldVisible, wholeFieldIsVisible] = vizInviz(childrenField);
  const [input, span] = inputAndSpan(childrenField);
  const [changeToEditMode, changeToViewMode, mode] = evMode(input, span);
};


const extendReferenceField = field => {

  field.ensureEditModeAnd = value => {
    if ('edit' !== mode()) { changeToEditMode(); }
    receiveValue(value);
  };

  field.ensureViewModeAnd = value => {
    if ('view' !== mode()) { changeToViewMode(); }
    receiveValue(value);
  };

  const receiveValue = value => {
    if (!value) { return receiveTheEmptyValue(); }

    // Don't show empty reference fields when in view mode.
    input.value = value;
    anchor.innerText = value;
    if (!wholeFieldIsVisible()) { makeWholeFieldVisible(); }
  }

  const receiveTheEmptyValue = () => {
    if ('view' == mode() && wholeFieldIsVisible()) {makeWholeFieldInvisible();}
    input.value = '';  // #here1
    anchor.innerText = '';
    if ('edit' == mode() && !wholeFieldIsVisible()) {makeWholeFieldVisible();}
  }

  field.fieldValue = () => { return input.value; };

  const fieldEl = field.element();
  const [makeWholeFieldInvisible, makeWholeFieldVisible, wholeFieldIsVisible] = vizInviz(fieldEl);
  const [input, span] = inputAndSpan(fieldEl);
  const [changeToEditMode, changeToViewMode, mode] = evMode(input, span);

  const anchor = span.children[0];  // not okay #open [#882.L]
  if ('A' !== anchor.nodeName) {
    throw("anchor not found for " + field.key);
  }

  anchor.onclick = onClickReferenceLink;
};


const vizInviz = field => {

  const makeWholeFieldInvisible = () => { field.style.display = 'none'; };

  const makeWholeFieldVisible = () => { field.style.display = 'flex'; };

  const wholeFieldIsVisible = () => {return ('none' !== field.style.display);};

  return [makeWholeFieldInvisible, makeWholeFieldVisible, wholeFieldIsVisible];
};


const evMode = (input, span) => {

  const changeToEditMode = () => {
    hide(span);
    show(input);
    state.mode = 'edit';
  };

  const changeToViewMode = () => {
    show(span);
    hide(input);
    state.mode = 'view';
  };

  const mode = () => {
    return state.mode;
  };

  const state = {'mode': 'view'};

  return [changeToEditMode, changeToViewMode, mode];
};


const inputAndSpan = fieldEl => {  // not okay #open [#882.L]

  const fieldBodyDiv = fieldEl.children[1];

  const input = fieldBodyDiv.children[1];
  if ('INPUT' !== input.nodeName) {
    throw("input not found for " + field.key);
  }

  const span = fieldBodyDiv.children[0];
  if ('SPAN' !== span.nodeName) {
    throw("span not found for " + field.key);
  }

  return [input, span];
};


const extendCommonField = field => {

  field.ensureEditModeAnd = value => {
    if ('edit' !== mode()) { changeToEditMode(); }
    receiveValue(value);
  };

  field.ensureViewModeAnd = value => {
    if ('view' !== mode()) { changeToViewMode(); }
    receiveValue(value);
  };

  const changeToEditMode = () => {
    input.removeAttribute('readonly');
  };

  const changeToViewMode = () => {
    input.setAttribute('readonly', 'readonly');
  };

  const mode = () => {
    return input.hasAttribute('readonly') ? 'view' : 'edit';
  };

  const receiveValue = value => {
    input.value = value || '';  // #here1
  };

  field.fieldValue = () => {
    return input.value;
  };

  const input = field.element();
};


const extendPermanantlyReadOnlyField = field => {
  field.ensureViewModeAnd = value => {
    input.value = value || '';
  };
  const input = field.element();
};


// ===== Buttons =====

const defineTheGetRandomEntityButton = (o, btn) => {
  o.mainAction(() => {
    const onEntity = (entity) => {
      mainForm.ensureViewModeAndReceiveEntity(entity);
      o.doneWorking();
    };
    const args = [collPath];
    codec.requestJSON('retrieve_random_notecard', args).then(onEntity);
  });
  o.textWhileWorking('Retrieving…');
};


const defineTheEditButton = (o, btn) => {
  o.mainAction(() => {
    mainForm.ensureState('EDITING');
  });
  o.isSynchronous();
};


const defineTheCancelEditingButton = (o, btn) => {
  o.mainAction(() => {
    // #todo: this resets the form to a pristine state. but where?
    mainForm.ensureState('READ_ONLY');
  });
  o.isSynchronous();
};


const defineTheSubmitButton = (o, btn) => {
  o.mainAction(() => {
    const ent = mainForm.requireCurrentEntity(()=>{return 'submit';});
    if (!ent) { o.doneWorking(); return; }
    const args = _buildArgsForSubmit(ent);
    if (!args) { o.doneWorking(); return; }  // maybe no change in form

    const onEntity = (entity) => {
      // this is a somewhat more arbitrary UI behavior choice:
      // on successful submit, pop back out of edit mode
      mainForm.ensureViewModeAndReceiveEntity(entity);
      o.doneWorking();
    };
    const onReject = (wat) => {
      log("got reject: " + wat);
    };
    log("sending update_notecard " + args.join(' '));
    codec.requestJSON('update_notecard', args).then(onEntity, onReject);
  });
  o.textWhileWorking('Processing…');
};


const onClickReferenceLink = (() => {
  // we could wire this like buttons and lock out concurrent clicks 1 day #todo
  const mainAction = ev => {

    const eid = ev.target.innerText;
    log('go daddy ' + eid);

    const onEntity = ent => {
      log('wahoo worked');
      mainForm.ensureViewModeAndReceiveEntity(ent);
    };

    const args = [eid, collPath];
    codec.requestJSON('retrieve_notecard', args).then(onEntity);
    return false;
  };

  return mainAction;
})();


const defineTheSayHelloToPhoButton = (o, btn) => {
  o.mainAction(() => {
    const onLines = (lines) => {
      log('wahoo done! here is lines:');
      let lineno = 0
      lines.forEach(line => {
        lineno += 1;
        log(`line ${lineno}: ${line}`);
      });
      o.doneWorking();
    };
    codec.requestLines('hello_to_pho', ['aa', 'bb']).then(onLines);
  });
  o.textWhileWorking('Saying Hello…');
};


// ===== Longer Button Stuff =====

const _buildArgsForSubmit = (ent) => {

  const args = [collPath];
  args.push(ent.identifier);
  const countBefore = args.length;

  mainFormFields.forEach((field) => {
    if (!field.isEditable()) { return; }

    const existingValue = field.encodeValue(ent[field.key]);
    const requestedValue = field.fieldValue();

    const existingIsSomething = isSomething(existingValue);
    const requestedIsSomething = isSomething(requestedValue);

    if (existingIsSomething) {
      if (requestedIsSomething) {
        if (existingValue === requestedValue) {
          /* hi. no change in value. do nothing. */
        } else {
          args.push('update_attribute', field.key, requestedValue);
        }
      } else {
        args.push('delete_attribute', field.key);
      }
    } else if (requestedIsSomething) {
      args.push('create_attribute', field.key, requestedValue);
    } else {
      /* hi. it wasn't set before and it's not set now. do nothing. */
    }
  });

  if (countBefore === args.length) {
    log("OHAI: no change in form. not sumitting.");
    return;
  }

  return args;
};


// ===== Define the Main Form Controller (2-state state machine) =====

const defineMainForm = () => {

  const exports = {};


  // -- stuff about the current entity

  exports.ensureViewModeAndReceiveEntity = ent => {
    // it won't let you change state without having an entity set.
    // be sure you are in read-only mode before you repopulate the form.
    state.currentEntity = ent;
    exports.ensureState('READ_ONLY');
    _repopulateForm(ent);
  };

  exports.requireCurrentEntity = verbPhraser => {
    const ent = state.currentEntity;
    if (!ent) {
      log("OOPS: can't " + verbPhraser() + " because no entity loaded yet.");
      return;
    }
    return ent;
  };


  // -- stuff about the current form state (there are only 2 modes)

  exports.ensureState = stateName => {
    if (state.stateName === stateName) {
      return;
    }
    if ('READ_ONLY' === stateName) {
      return changeToReadOnlyState();
    }
    if ('EDITING' === stateName) {
      return changeToEditing();
    }
    throw("not a state: '"+stateName+"'");
  };

  const changeToEditing = () => {
    withCurrentEntityChangeToThisState('EDITING', _doChangeToEditing);
  };

  const changeToReadOnlyState = () => {
    withCurrentEntityChangeToThisState('READ_ONLY', _doChangeToNotEditing);
  };

  const withCurrentEntityChangeToThisState = (stateName, callMe) => {
    const ent = exports.requireCurrentEntity(()=>{return "change to '"+stateName+"'";});
    if (!ent) { return; }
    state.stateName = stateName;
    callMe(ent);
  };

  const state = {
    'currentEntity': null,
    'stateName': null,
  };

  return exports;
};


const _doChangeToEditing = currentEntity => {
  mainFormFields.forEach(formal => {
    if (!formal.isEditable()) { return; }
    const value = currentEntity[formal.key];
    formal.ensureEditModeAnd(value);
  });
  mainFormButtons.changeToEditing();
};


const _doChangeToNotEditing = currentEntity => {
  mainFormFields.forEach(formal => {
    if (!formal.isEditable()) { return; }
    const value = currentEntity[formal.key];
    formal.ensureViewModeAnd(value);
  });
  mainFormButtons.changeToNotEditing();
};


const _repopulateForm = ent => {
  mainFormFields.forEach(formal => {
    const value = ent[formal.key];
    formal.ensureViewModeAnd(value);
  });
};


// ===== Define the Main Form Button Controller  =====

const defineMainFormButtons = () => {
  /* NOTE the exports of this "controller" are intended to be called only from
   * the main form controller (and only in one place each for each function).
   * We put them inside a scope to keep the button variable from cluttering
   * up the global namespace. We put them in a separate controller from the
   * main form controller to keep them from cluttering up that controller.
   */

  const exports = {};

  exports.changeToEditing = () => {
    hide(closedLock);
    show(openLock);
    hide(editBtn);
    show(cancelBtn);
    show(submitBtn);
  };

  exports.changeToNotEditing = () => {
    show(closedLock);
    hide(openLock);
    show(editBtn);
    hide(cancelBtn);
    hide(submitBtn);
  };

  const o = getElementById;
  const closedLock = o('closedLock');
  const openLock = o('openLock');
  const editBtn = o('editBtn');
  const cancelBtn = o('cancelBtn');
  const submitBtn = o('submitBtn');

  wireButton(defineTheEditButton, editBtn);
  wireButton(defineTheCancelEditingButton, cancelBtn);
  wireButton(defineTheSubmitButton, submitBtn);

  wireButton(defineTheGetRandomEntityButton, 'randomBtn');
  wireButton(defineTheSayHelloToPhoButton, 'helloBtn');

  return exports;
};


// ===== Experimental Button Toolkit (just a sketch) =====

const wireButton = (definition, btn) => {
  if ('string' === typeof(btn)) {
    btn = getElementById(btn);
  }
  const yikesName = btn.getAttribute('id');
  const relay = {};
  relay.mainAction = mainAction => {
    state.mainAction = mainAction;
  };
  relay.textWhileWorking = text => {
    state.textWhileWorking = text;
    state.isSynchronous = false;
  };
  relay.isSynchronous = () => {
    state.isSynchronous = true;
  };
  const state = {'isWorking': false};
  definition(relay);
  btn.onclick = e => {
    if (state.isSynchronous) {
      return state.mainAction();
    }
    if (state.isWorking) {
      log("'" + yikesName + "' is working. cancelling (not really)…");
      relay.doneWorking();
      return;
    }
    state.nonWorkingText = btn.innerText;
    // btn.classList.add('is-loading'); cool but you need a timeout #here2
    btn.innerText = state.textWhileWorking;
    state.isWorking = true;
    state.mainAction();
  };

  relay.doneWorking = () => {
    if (!state.isWorking) {
      return;
    }
    // btn.classList.remove('is-loading');  #here2
    btn.innerText = state.nonWorkingText;
    state.isWorking = false;
  };
}


// ===== Support for Elements  =====

const hide = (btn) => {
  btn.classList.add('is-hidden');
};


const show = (btn) => {
  btn.classList.remove('is-hidden');
};



// ===== Support for Form Processing ====

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
      log(`STRANGE: why do we have this type: "${typ}"`);
      return true;
  }
};


// ===== Flush Forward-Declarations =====

const getElementById = s => { return document.getElementById(s); };
const log = msg => { console.log(msg); };


const mainForm = defineMainForm();
const mainFormButtons = defineMainFormButtons();
const mainFormFields = defineMainFormFields().fields;


// ===== Codec =====

const defineCodec = () => {

  const exp = {};

  exp['requestJSON'] = (commandName, args) => {
    return requestJSON(buildShell(commandName, args || []));
  };

  exp['requestLines'] = (commandName, args) => {
    return requestLines(buildShell(commandName, args || []));
  };

  const requestJSON = pyshell => {
    return new Promise((resolve, reject) => {
      requestLines(pyshell).then(lines => {
        const bigString = lines.join('');
        log(`big string: (${bigString.length} characters)`);
        resolve(JSON.parse(bigString));
      });
    });
  };

  const requestLines = pyshell => {

    return new Promise((resolve, reject) => {

      // State
      const stdouts = [];

      // pyshell.send('some user data')

      pyshell.on('message', message => {

        if (! message) {
          return reject("empty message");
        }

        const idx = message.indexOf(': ');

        if (-1 === idx) {
          return reject(`no header in message: ${message}`);
        }

        const type = message.slice(0, idx);

        if ('stderr' === type) {
          return log(message);  // or tail
        }

        if ('stdout' !== type) {
          return reject(`strange type: ${type}`);
        }

        const tail = message.slice(idx + 2);  // be careful
        // log(`receceived stdout payload: ${tail}`);
        stdouts.push(tail);
      });

      pyshell.end((err, code, signal) => {
        if (err) {
          log("FOR NOW not throwing, might be UI error: " +err);
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
    return new PythonShell(paths.backendPath, options);
  };

  const commonOptions = {
    scriptPath: paths.monoRepoDir,
    pythonPath: _PYTHON,
    pythonOptions: ['-u'],  // stdin, stdout & stderr unbuffered
    mode: 'text',
    cwd: paths.monoRepoDir,  // big flex: be in same directory as during dev
  };

  return exp;
};


const definePaths = () => {
  const exports = {};
  const path = require('path');

  const srcDir = path.resolve(__dirname);
  const phoGuiDir = path.join(srcDir, '..');  // npm start run from here
  const projectDir = path.join(phoGuiDir, '..');
  const monoRepoDir = path.join(projectDir, '..');  // we develop from here

  const projRelpath = projectDir.substring(monoRepoDir.length+path.sep.length);

  exports.monoRepoDir = monoRepoDir;  // when we call to backend, cd to here
  exports.backendPath = path.join(projRelpath, _BACKEND);
  exports.collectionPath = path.join('no-see', _COLLECTION);  // fragile af

  return exports;
};


const paths = definePaths();
const collPath = paths.collectionPath;

const codec = defineCodec();

/*
 * #history-A.3: overhaul for better compartmentalization with this one pattern
 * #history-A.2: spike codec and random button
 * #history-A.1: remove screen recording tutorial code
 * #born (from tutorial)
 */
