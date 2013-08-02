# the API action class normalizer instance method API

This is the field-level normalization API.

experimentally:

    class Foo < Face::API::Action

      params [ :email, :normalizer, true ]    # the `true` means we'll do
                                              # it with an instance method..
      # ..

    private

      def normalize_email y, x, value_if_ok   # note the form `normalize_<foo>`
        if some_rx =~ x                       # if the email looks good,
          value_if_ok[ x.downcase ]           # we weirdly downcase it
          true
        else
          y << "i hate this email."           # write errmsgs like this
          false
        end
      end
    end

The above lets us focus on what normalization means for the particular
field, and insulates us from both how the data is stored and how
we are wired for eventing.

We avoided this in the past, but as a courtesty to the caller, the
true-ish-ness / false-ish-ness of the result must be able to be used as
an indication of whether the field value can be considered valid or not
(respectively).

the signature is such that the normalizer passed in the field specification
may one day be an arbitrary callable. no assumption is made of side-effects
from the perpective of the caller.

when a field indicates itself as having a `normalizer`, it is guaranteed
to be run (the normalization routine, whatever it is) in the normal
API lifecycle, regardless of whether an actual parameter was provided.

(note: the weird order of arguments that amounts to
[ <no>, <input-value>, <yes> ] stems from the fact that we like result procs
usually to go at the end, by we like `y` yielders to go always at the
beginning.)

(note too that for a field that could potentially get normalized into
e.g `false` or `nil` and still be valid, this is why using the result
alone won't work for that.)

~
