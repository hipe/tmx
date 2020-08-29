'use strict';

const _COLLECTION = '../pho-doc/fragments';  // ..
const _BACKEND = 'backend.py';
const _PYTHON = 'python3';  // ..


const { PythonShell } = require('python-shell');


// ===== Fields =====

const defineMainFormFields = () => {
  // experimental formal fields definitions [#882.M]

  const exports = {};

  const fields = [
  {key: "parent", isRef: true, element: ()=>{return parentField;}},
  {key: "previous", isRef: true, element: ()=>{return previousField;}},
  {key: "identifier", editable: false, element: ()=>{return identifierInput;}},
  {key: "heading", element: ()=>{return headingInput;}},
  {key: "document_datetime", editable: false, element: ()=>{return datetimeInput;}},
  {key: "body", element: ()=>{return bodyTextarea;}},
  {key: "next", isRef: true, element: ()=>{return nextField;}},
  {key: "children", customExtend: fld => {extendChildrenField(fld, childrenField);}},
  ];

  exports.enterCreating = () => {
    viaName.parent.enterViewing();  // #here3
    hide(previousField);
    hide(identifierInput);
    hide(datetimeInput);
  };

  exports.exitCreating = () => {
    viaName.parent.enterEditing();  // #here3
    show(previousField);
    show(identifierInput);
    show(datetimeInput);
  };

  exports.enterUpdating = () => {
    eachField(field => {
      if (!field.isEditable()) { return; }
      field.enterEditing();
    });
  };

  exports.enterViewing = () => {
    eachField(field => {
      if (!field.isEditable()) { return; }
      field.enterViewing();
    });
  };

  const o = getElementById;
  const parentField = o('parentField');
  const previousField = o('previousField');
  const identifierInput = o('identifierInput');
  const headingInput = o('headingInput');
  const datetimeInput = o('datetimeInput');
  const bodyTextarea = o('bodyTextarea');
  const nextField = o('nextField');
  const childrenField = o('childrenField');

  const eachField = f => { fields.forEach(f); };
  const viaName = {};
  eachField(field => {
    viaName[field.key] = field;
    extendField(field);
  });

  exports.forEachField = eachField;
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

  field.fieldValue = () => { return input.value; };

  field.encodeValue = arr => {
    if (!(arr && arr.length)) { return ''; }
    return arr.join(', ');
  }

  field.receiveValue = value => {
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
  const [enterEditing, enterViewing, mode] = evMode(input, span);

  field.enterEditing = enterEditing;
  field.enterViewing = enterViewing;
};


const extendReferenceField = field => {

  // throughout all the exposures below, implement this:
  // Don't show empty reference fields when in view mode.

  field.receiveValue = value => {
    if (!value) { return receiveTheEmptyValue(); }
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

  field.enterEditing = () => {  // #here3
    enterEditing();  // hide the span; show the input
    if (!wholeFieldIsVisible()) { makeWholeFieldVisible(); }
  };

  field.enterViewing = () => {  // #here3
    if ('' == input.value && wholeFieldIsVisible()) {  // #here1
      makeWholeFieldInvisible();
    }
    enterViewing();  // hide the input; show the span
  };

  field.fieldValue = () => { return input.value; };

  const fieldEl = field.element();
  const [makeWholeFieldInvisible, makeWholeFieldVisible, wholeFieldIsVisible] = vizInviz(fieldEl);
  const [input, span] = inputAndSpan(fieldEl);
  const [enterEditing, enterViewing, mode] = evMode(input, span);

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

  const enterEditing = () => {
    hide(span);
    show(input);
    state.mode = 'edit';
  };

  const enterViewing = () => {
    show(span);
    hide(input);
    state.mode = 'view';
  };

  const mode = () => {
    return state.mode;
  };

  const state = {'mode': 'view'};

  return [enterEditing, enterViewing, mode];
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

  field.enterEditing = () => {
    input.removeAttribute('readonly');
  };

  field.enterViewing = () => {
    input.setAttribute('readonly', 'readonly');
  };

  const mode = () => {
    return input.hasAttribute('readonly') ? 'view' : 'edit';
  };

  field.receiveValue = value => {
    input.value = value || '';  // #here1
  };

  field.fieldValue = () => {
    return input.value;
  };

  const input = field.element();
};


const extendPermanantlyReadOnlyField = field => {
  field.receiveValue = value => {
    input.value = value || '';
  };
  const input = field.element();
};


// ===== Buttons =====

const defineTheGetRandomEntityButton = (o, btn) => {
  o.mainAction(() => {
    const onEntity = (entity) => {
      mainForm.ensureStateWith('VIEWING', entity);
      o.doneWorking();
    };
    const args = [collPath];
    codec.requestJSON('retrieve_random_notecard', args).then(onEntity);
  });
  o.textWhileWorking('Retrieving…');
};


const defineTheAddChildButton = (o, btn) => {
  o.mainAction(() => {
    mainForm.transitionFromTo('UPDATING', 'CREATING');
  });
  o.isSynchronous();
};


const defineTheEditButton = (o, btn) => {
  o.mainAction(() => {
    mainForm.transitionFromTo('VIEWING', 'UPDATING');
  });
  o.isSynchronous();
};


const defineTheCancelEditingButton = (o, btn) => {
  o.mainAction(() => {
    const two = mainForm.formEntityAndState();
    if (!two) { return; }
    const [_, stateName] = two;
    switch (stateName) {
      case 'UPDATING':
        // #todo: this resets the form to a pristine state. but where?
        return mainForm.transitionFromTo('UPDATING', 'VIEWING');
      case 'CREATING':
        return mainForm.transitionFromTo('CREATING', 'UPDATING');
    }
    oops("don't know how to cancel from " + stateName);
  });
  o.isSynchronous();
};


const defineTheSubmitButton = (o, btn) => {
  o.mainAction(() => {
    const two = mainForm.formEntityAndState();
    if (!two) { o.doneWorking(); return; }
    const [ent, stateName] = two;
    let which, args;
    switch (stateName) {
      case 'CREATING':
        args = _buildArgsForCreate(ent);
        which = 'create_notecard';
        break;
      case 'UPDATING':
        args = _buildArgsForUpdate(ent);
        which = 'update_notecard';
        break;
    }
    if (!args) { o.doneWorking(); return; }  // maybe no change in form

    const onEntity = (entity) => {
      // this is a somewhat more arbitrary UI behavior choice:
      // on successful submit, pop back out of edit mode
      mainForm.ensureStateWith('VIEWING', entity);
      o.doneWorking();
    };
    const onReject = (wat) => {
      log("got reject: " + wat);
    };

    log("sending " + which + " " + args.join(' '));
    codec.requestJSON(which, args).then(onEntity, onReject);
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
      mainForm.ensureStateWith('VIEWING', ent);
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

const _buildArgsForUpdate = (ent) => {

  const args = [collPath];
  args.push(ent.identifier);
  const countBefore = args.length;

  mainFormFields.forEachField(field => {
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


const _buildArgsForCreate = (ent) => {  // painful

  const args = [collPath];
  const countBefore = args.length;

  let parentField;

  mainFormFields.forEachField(field => {
    if (!field.isEditable()) { return; }
    if ('parent' === field.key) { parentField = field; return; }

    const existingValue = field.encodeValue(ent[field.key]);
    const requestedValue = field.fieldValue();

    const existingIsSomething = isSomething(existingValue);
    const requestedIsSomething = isSomething(requestedValue);

    if (existingIsSomething) {
      if (requestedIsSomething) {
        if (existingValue === requestedValue) {
          // no change in value suggests that the default text is unchagned
        } else {
          // change in value means they changed the default text, right?
          args.push(field.key, requestedValue);
        }
      } else {
        // maybe the user deleted the default text and made it blank
      }
    } else if (requestedIsSomething) {
      // something from nothing is normal
      args.push(field.key, requestedValue);
    } else {
      // hi. it wasn't set before and it's not set now. do nothing.
    }
  });

  if (ent.parent != parentField.fieldValue()) {
    oops("for now, can't change parent in add child form"); return;
  }

  if (countBefore === args.length) {
    log("OHAI: no change in add child form. not sumitting."); return;
  }

  args.push('parent', ent.parent);

  return args;
};


// ===== Define the Main Form Controller (4-state state machine) =====

const defineMainForm = () => {

  const exports = {};

  exports.ensureStateWith = (to, ent) => {
    let tf;  // annoying that it won't let me use const 2x below wat do #todo
    if (state.name === to) {
      tf = functionForWith();
    } else {
      tf = functionForTransitionToWith(to);
    }
    if (!tf) { return; }
    changeState(to, tf)(ent);
  };

  exports.transitionFromTo = (from, to) => {
    const tf = functionForTransitionTo(to);
    if (!tf) { return; }
    changeState(to, tf)();
  };

  const changeState = (to, fn) => {
    const head = (state.name === to) ? state.name : (state.name + '->' + to);
    log(head + ' ' + fn);
    state.name = to;
    return functions[fn];
  };

  exports.formEntityAndState = () => {
    switch (state.name) {
      case 'UPDATING':
        return [state.parentEntity, state.name];
      case 'CREATING':
        return [state.childEntity, state.name];
    }
    oops("can't get form entity from " + state.name);
  };

  const transitions = {  // commit comment at #history-A.4 expounds
    'BEGINNING': {
      'transitionTo': {
        'VIEWING': { 'with': 'enterViewingForTheFirstTime' },
      },
    },
    'VIEWING': {
      'transitionTo': {
        'UPDATING': { 'without': 'changeFromViewingToUpdating' },
      },
      'receiveNewEntity': 'receiveNewEntityWhileInViewingMode',
    },
    'UPDATING': {
      'transitionTo': {
        'VIEWING': {
          'without': 'changeFromUpdatingToViewingBecauseCancel',
          'with': 'changeFromUpdatingToViewingBecauseSuccess',
        },
        'CREATING': { 'without': 'changeFromUpdatingToCreating' },
      },
    },
    'CREATING': {
      'transitionTo': {
        'UPDATING': { 'without': 'changeFromCreatingToUpdating' },
        'VIEWING': { 'with': 'changeFromCreatingToViewing' },
      }
    },
  };

  const functionForTransitionToWith = to => {
    const tn = transitionNode(to);
    if (!tn) { return; }
    const w = tn.with;
    if (!w) { return oops("can't go from "+state.name+" to "+to+" w/ arg"); }
    return w;
  };

  const functionForTransitionTo = to => {
    const tn = transitionNode(to);
    if (!tn) { return; }
    const wo = tn.without;
    if (!wo) { return oops("can't go from "+state.name+" to "+to+" w/o arg"); }
    return wo;
  };

  const transitionNode = to => {
    const node = transitions[state.name].transitionTo[to];
    if (!node) { return oops("can't transition from "+state.name+" to "+to); }
    return node;
  };

  const functionForWith = () => {
    const fn = transitions[state.name].receiveNewEntity;
    if (!fn) { return oops('' + state.name + 'has no receiveNewEntity'); }
    return fn;
  };

  const o = {};

  o['changeFromCreatingToViewing'] = ent => {
    exitCreating();
    enterViewing()
    receive(ent);
  };

  o['changeFromCreatingToUpdating'] = () => {
    exitCreating()
    repopulate(state.parentEntity);
  };

  o['changeFromUpdatingToCreating'] = () => {
    const childEntity = buildHandWrittenEntityForCreating(state.parentEntity);
    state.childEntity = childEntity;
    clearForm();
    mainFormFields.enterCreating();
    mainFormButtons.enterCreating();
    repopulate(childEntity);
  };

  o['changeFromUpdatingToViewingBecauseSuccess'] = ent => {
    clearForm();
    enterViewing();
    receive(ent);
  };

  o['changeFromUpdatingToViewingBecauseCancel'] = () => {
    enterViewing();
  };

  o['changeFromViewingToUpdating'] = () => {
    enterEditing();
  };

  o['enterViewingForTheFirstTime'] = ent => {
    receive(ent);
  };

  o['receiveNewEntityWhileInViewingMode'] = ent => {
    receive(ent);
  };

  const functions = o;

  const exitCreating = () => {
    state.childEntity = null;
    clearForm();
    mainFormFields.exitCreating();
    mainFormButtons.exitCreating();
  };

  const enterEditing = () => {
    mainFormFields.enterUpdating();
    mainFormButtons.enterUpdating();
  };

  const enterViewing = () => {
    mainFormFields.enterViewing();
    mainFormButtons.enterViewing();
  };

  const clearForm = () => {
    eachField(field => {
      field.receiveValue(null);
    });
  };

  const receive = ent => {
    state.parentEntity = ent;
    repopulate(ent);
  };

  const repopulate = ent => {
    eachField(field => {
      field.receiveValue(ent[field.key]);
    });
  };

  const eachField = f => { mainFormFields.forEachField(f); };

  const state = {
    'name': 'BEGINNING',
  };

  return exports;
};


const buildHandWrittenEntityForCreating = parentEntity => {
  return {
    'parent': parentEntity.identifier,
    'heading': '«your heading here»',
    'body': "«your body here»\n«line 2»\n",
  };
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

  exports.enterCreating = () => {
    hide(addChildBtn);
  };

  exports.exitCreating = () => {
    show(addChildBtn);
  };

  exports.enterUpdating = () => {
    hide(closedLock);
    show(openLock);
    hide(editBtn);
    show(cancelBtn);
    show(addChildBtn);
    show(submitBtn);
  };

  exports.enterViewing = () => {
    show(closedLock);
    hide(openLock);
    show(editBtn);
    hide(cancelBtn);
    hide(addChildBtn);
    hide(submitBtn);
  };

  const o = getElementById;
  const closedLock = o('closedLock');
  const openLock = o('openLock');
  const editBtn = o('editBtn');
  const cancelBtn = o('cancelBtn');
  const addChildBtn = o('addChildBtn');
  const submitBtn = o('submitBtn');

  wireButton(defineTheEditButton, editBtn);
  wireButton(defineTheCancelEditingButton, cancelBtn);
  wireButton(defineTheAddChildButton, addChildBtn);
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
const oops = msg => { log("OOPS: " + msg); };
const log = msg => { console.log(msg); };


const mainForm = defineMainForm();
const mainFormButtons = defineMainFormButtons();
const mainFormFields = defineMainFormFields();


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
 * #history-A.4: enter more complex state machine
 * #history-A.3: overhaul for better compartmentalization with this one pattern
 * #history-A.2: spike codec and random button
 * #history-A.1: remove screen recording tutorial code
 * #born (from tutorial)
 */
