# singular plural acrosss modalities :[#036]

singular-plural pairs were created for the convenience of being able to
specify a whole array as one atom for a formal parameter that has an
argument arity with a ceiling of more than one. BUT:

  • maybe this is only useful from API.

  • from niCLI, we don't want *both* of these to be accessible
    because it clutters the generated UI. there should only appear
    to be (and actually be) one.

    here we see a mandatory #mode-tweaking: we omit entirely the plural
    form. when the formal node is expressed in the option parser,
    it should work in the expected way, pushing to the same array
    with each invocation. when expressed in the arguments, well, etc.

  • from iCLI we antipate doing (or having done?) the same, but in
    contrast to our non-interactive counterpart, we will use the
    *plural* (not singular) form of the name in the UI.



### inborn defaults and pushers:"section 2"

because iCLI is approaching a feeling of "edit in place" (and whatever
other reason), it is best that defaults for primitivesques are written
as plain old ivars in the component in its initialize method. (in fact
it was designed to work this way, because it has the benefit of taking
up the least mental real estate, being that it is as transparent as could
be when reading in code form.)

this is fine and dandy but for these gotchas:

  1) if you *did* try and specify defaults as you normally would for the
     other modes (in the association definition), they would never trigger
     because something would always already be there in the ivars.
     (but this should be unsurprising for someone familiar with what
     defaulting is in [ac]/[ze].)

  2) for { more than one argument arity | plural-counterpart } formal
     nodes, these nodes need special handling in niCLI. consider:

in the bundled modalities,

  • API can be ignorant of these "intuitive defaults" - whether the
    singular or plural is invoked, it is meant to overwrite completely
    any array that is already there.

  • what we do in niCLI is the focus of the surrounding section.

  • in iCLI, it attempts its own edit-in-place treatment (..)

so in niCLI to achieve aggregation *and* intuitive defaults is a bit
tricky because it requires adding a new element of state:

    the polyadic primitivesque that has intuitive defaults must keep
    track of whether it is in the default state.

when such a node is invoked,

    if it is in the default state,
      overwrite the existing array.
      flip the bit so it is not in the default state.
    otherwise, push to the existing array.

we call this "long-running" state "pristinity" (because it's not a word
so it's easy to track).

whew!
