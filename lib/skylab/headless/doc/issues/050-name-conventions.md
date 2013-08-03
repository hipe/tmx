# name conventions

## some thoughts on the name `name`

Don't use it. As a complete variable or method name, "name" is so vague
that it itself is almost useless as a name. Is it a symbol or a string?
It is appropriate as a label for a user interface or is it used internally
as a key? Is it unique in some context and suitable as an identifier (key),
and if so what is the context, how broad is the namespace?

These distinctions are *very* important, and get very muddled
when we start calling things simply "name". Yes there's context, sure,
and you can document somewhere what is intended for the particular symbol,
but that doesn't help the fact that whenever I read `name` as a name I
immediately cringe at the thought that I will have to at that moment guess
which it is.

Use more specific names for variables or methods that represent names.

  + `foo_label` or `bar_string` is nice, the former suggests that it is
  suitable for display to the user, the latter is at least being explicit.

  + `normalized_name` (or `local_normal_name`) is better. When I see "normalized"
  here i think "symbol", which is a step in the right direction. *however*,
  in some contexts a `local_normal_name` is still too vague.

  (at present we are trending towards using variously (`foo.name.local_normal`,
  `foo.name.anchored_normal`, and `foo.local_normal_name` and
  `foo.anchored_normal_name` as our four universal, unamibguous meta-names.)


### with one exception..

An important exception to all of the above, and one that is in itself
telling, is that we *can* use the name `name` to hold a name function.
This is because when you see something like `foo.name.to_slug` it is
imminently readable and not ambiguous (if slug has meaning to you).

However, when you call a variable for holding name functions `name`, still
please be conscientious of all of the above concerns and make a comment
where necessary if ever it is not clear from that one line of code
what is in that particular name.


## functions / methods


### string-rendering methods

  + `to_s`, `to_str` -
  guess what: for new code, i almost never use either of them. Unless i
  really (really) want it to have the look of being interpolated in a string
  (and i can't think of one instance where i do implicitly), i opt for
  one of the below. Say what you mean - don't let the objects put words in
  your mouth, and don't put objects ..

  + `string`, `foo_string` -
  result must be a string. must take 0 args. frequently if the
  method has "string" in the name (as opposed to e.g. "render") it implies that
  the string is not collapsed down to one mode (that it is not styled).
  (also see notes at `render` for further distinction..)

  + `text` (vs. `string`)
  It's a subtle, semantic distinction: `text` is a subset of `string`
  that is for sure suitable to be read by humans (we don't know yet if
  it should imply that it is already styled or not). (We used to call it
  `message` but that seemed *too* pointed).

  + `line`, `foo_line` -
  like above, but of course implies that it probably should not have
  newlines in it. this might be styled for the particular modality.

  + `lines`, `foo_lines` -
  must result in enumerable, e.g. array. usually (always?) takes no args.
  this might be styled for the particular modality.

  (saying "line" or "lines" usually implies a certain mode..)

  + `render`, `render_foo` -
  (at one point we thought .. but then we were like ..)
  rendering freqently happens internally (read: private methods).
  the optimal shape for the method depends largely on what is being done;
  e.g a table might render its each row which would involve rendering each cel.
  memory might be prohibitve to join all the rows into one big string,
  but at the cel-level it might be a best fit to result in strings from
  a method call, etc.
  this said, any such render method that meets any one of the below
  critera must meet the whole criteria, for the below (mutually
  exclusive) variants of form:
  if the method is to take a yielder, it must a) take it as the first
  argument and b) it is strongly encouraged that your result be
  undefined.

  #### `render` means moving parts
  e.g I was trying to decide between `render` and `string` for a class
  that models a `find` command (think `ack`). At first i was like, "string"
  because it looks better, and i mean, it's a command, it's so close to
  a string already, yeah!? NO. The particular class tries to prevent itself
  from producing an invalid string representation of the command, so it
  is not "guaranteed" to produce a string; it is not "isomorphic" with a
  string. I chose "render" because it implies that it does some work, and
  that success is not guaranteed.

  ..

  + the above can have modifiers *after* them too (`foo_string_for_bar`)
  and the guidelines should generally still hold.


## exclamation points

  + they should of course never be used for methods that do not mutate
  the state of the reciever, but that is not to say that they should
  always be used for methods that do! (#todo this is an area of active
  inquiry)
_
    + they should be used as as shorthand for a boolean setter (`debug!`
    that sets a @do_debug for example) (`debug` by the way is a good
    example of a bad method name: is it a boolean? is it a function to
    call when debugging? is it the stream to write out to for debugging?
    is it an integer debug level?)
_
    + they should be used for a method that autovivifies the thing:
      `current_definition!.add_description desc`

    + they should be used to disambiguate from a possibly non-mutating
    form (whether or not it exists), as a high-information-density
    optimizer: `process_param_queue!`, distinct from a form with no '!',
    we can infer from the name that it processes the param queue *and*
    clears at least those items processed from the queue.

    + conversely, with a method like `enqueue`, we do *not* use the '!'
    in it, because it feels sort of like "push", and the name itself sort of
    implies that mutating is happening (and there is no non-mutating
    form that it needs to be disambiguated from).

  a world where exclamations were always used for methods that mutate
  the receiver would be an interesting world indeed, but it would
  probably be way too shouty (consdier basics like `push`). A world
  where there were always few side effects from method calls would also
  be interesting (..)
_
