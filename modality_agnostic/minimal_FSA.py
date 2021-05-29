"""The Minimal FSA Library :[#505]

- Mostly just keep track of what state you are in (as a name string) and
  assert that you can change into whatever other state name you set
- Compare the more complicated [#504], which adds structural representation
  of transitions and maybe actions
- Define your "formal" FSA with a dictionary whose string keys are the state
  names and whose values are tuples of strings, each string representing a
  state that can be transitioned to from that state. ("FFSA")
- The above's forward references will be asserted at definition time
- An *actual* FSA (just "FSA") is effectively just a FSA plus a string
  to keep track of which state it's in, and "locking":
- Derived from practice, you can "lock" temporarily the FSA using a string
  name. This allows you to lock out state changes while you do a particular
  operation, without neededing to add a node to the formal state (and two
  trasitions) just to achieve the locking effect
- Along the same lines as above, we allow you to enter into "failure lock"
  which locks out any further changes permanantly
- Attempts to move to an unreachable state or to change state when locked
  all give natural-souding and helpful error messages
- No support for UI integration (e.g., listeners) yet: all failures are
  currently raised as exceptions which are not yet part of the public API
- No coverage yet. early-abstracted from one client
"""


class Minimal_Formal_FSA:

    def __init__(self, **dct):
        keys = tuple(dct.keys())
        self.initial_state_name = keys[0]  # ..
        for k in keys:
            tup = dct[k]
            if not isinstance(tup, tuple):
                raise RuntimeError(f"must be tuple: {tup!r}")
            for kk in tup:
                if kk not in dct:
                    raise RuntimeError(f"not in left hand side: {kk!r}")
                assert kk in dct
        self.transitions_dictionary = dct

    def build_precondition_decorator(self, state_attr_name):
        return _build_FSA_precondition_decorator(
                state_attr_name, self.transitions_dictionary)

    def build_FSA(self):
        return _Minimal_FSA(self)


def _build_FSA_precondition_decorator(state_attr_name, dct):
    def decorator_maker(required_state_name):
        assert required_state_name in dct

        def decorator(orig_func):
            def use_func(self):
                assert self.ok  # VERY experimental
                state_name = getattr(self, state_attr_name)
                if required_state_name == state_name:
                    return orig_func(self)
                s_s = _sentences_for_FSA_method_precondition_failure(
                    orig_func.__name__, state_name, required_state_name)
                raise _FSA_Error(' '.join(s_s))
            return use_func
        return decorator
    return decorator_maker


class _Minimal_FSA:

    def __init__(self, ffsa):
        self._state_name = ffsa.initial_state_name
        self._transitions_dict = ffsa.transitions_dictionary
        self._is_mutable = True

    def move_to(self, state_name):
        if self._is_locked:
            raise _FSA_Error(' '.join(_FSA_s_s('move to', state_name, self)))
        if state_name not in self._transitions_dict[self._state_name]:
            s_s = _sentences_for_FSA_transition_not_allowed(
                state_name, self._state_name, self._transitions_dict)
            raise _FSA_Error(' '.join(s_s))
        self._transitions_dict[state_name]  # runtime validate meh #here7
        self._state_name = state_name

    def open_lock(self, lock_name):
        if self._is_locked:
            raise _FSA_Error(' '.join(_FSA_s_s('open lock', lock_name, self)))

        from contextlib import contextmanager as _contextmanager

        @_contextmanager
        def do_open_lock():
            self.enter_lock(lock_name)
            yield
            self.exit_lock(lock_name)  # not sure if this covers it
        return do_open_lock()

    def enter_lock(self, lock_name):
        if self._is_locked:
            raise _FSA_Error(' '.join(_FSA_s_s('lock as', lock_name, self)))
        self._is_mutable, self._lock_is_mutable = False, True
        self._state_name_when_unlocked = self._state_name
        self._state_name = lock_name

    def exit_lock(self, lock_name):
        if self._is_mutable:
            return self._cannot_exit_lock(lock_name)
        if self._lock_is_permanant:
            return self._cannot_exit_lock(lock_name)
        if self._state_name != lock_name:
            return self._cannot_exit_lock(lock_name)
        self._state_name = self._state_name_when_unlocked
        del self._state_name_when_unlocked
        del self._lock_is_mutable
        self._is_mutable = True

    def _cannot_exit_lock(self, lock_name):
        raise _FSA_s_s(' '.join(_FSA_s_s('exit lock', lock_name, self)))

    def failure_lock(self, lock_name):
        # you can enter failure lock (which is permanent) from any internal
        # state except if you are already failure-locked

        if self._is_locked and self._lock_is_permanant:
            msg = ' '.join(_FSA_s_s('failure lock as', lock_name, self))
            raise _FSA_Error(msg)
        self._is_mutable, self._lock_is_mutable = False, False
        self._state_name = lock_name

    @property
    def state_name(self):
        return self._state_name

    @property
    def _lock_is_permanant(self):  # assumed locked
        return not self._lock_is_mutable

    @property
    def _is_locked(self):
        return not self._is_mutable


# == Whiners

def _sentences_for_FSA_method_precondition_failure(
        func_name, state_name, required_state_name):
    yield f"Can't call '{func_name}' in current state."
    yield f"Must be in state '{required_state_name}' but state"\
          f" in '{state_name}'."


def _sentences_for_FSA_transition_not_allowed(
        arg_state_name, state_name, trans_dict):

    yield f"Can't transition from '{state_name}' to '{arg_state_name}'."
    if (splay := trans_dict.get(arg_state_name)) is None:
        yield "That state isn't even defined."
    elif 0 == (leng := len(splay)):
        yield "The current state is a terminal state (no way out)."
    elif 1 == leng:
        yield f"Can only transition to '{splay[0]}' from that state."
    else:
        yield f"There are {leng} other transitions to choose from."


def _FSA_s_s(verb_phrase_head, mixed_name, fsa):
    yield f"Can't {verb_phrase_head} {mixed_name!r}."
    noun_phrase = "FSA"  # placeholder for the idea
    if fsa._is_mutable:
        yield "{noun_phrase} is not locked."
    else:
        lock_name = fsa._state_name
        if fsa._lock_is_mutable:
            yield f"{noun_phrase} is locked as {lock_name!r}."
        else:
            yield f"{noun_phrase} is failure-locked as {lock_name!r}."


class _FSA_Error(RuntimeError):
    pass

# #born
