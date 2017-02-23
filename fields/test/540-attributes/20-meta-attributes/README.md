# numbering scheme

• a high-level overview is earliest because it is a common use-case
  (although this as a rationale contradicts other rationale..)

• `list` is earlier because it is a frequently used meta-parameter

• `enum` is before { would-be `flag` and } `boolean` because it is
   conceptually a dependant of [them]. (although in practice it is
   not implemented this way.)

• { would-be `flag` } is before `boolean` because it is lower-level
  and would be a dependant of flag conceptually.

• `custom_interpreter_method` before `component` b.c dependency

• `hook`, `default`, and `desc` are legacy, so last.

• `desc` is a high-level meta-attribute being that it pertains only
  to generated interfaces and not in interpretation logic.
