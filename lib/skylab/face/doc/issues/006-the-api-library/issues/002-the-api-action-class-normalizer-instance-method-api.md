# the API action class normalizer instance method API

experimentally:

    class Foo < Face::API::Action

      params [ :email, :normalizer, true ]    # the `true` means we'll do
                                              # it with an instance method..
      # ..

    private

      def normalize_email y, x, value_if_ok   # note the form `normalize_<foo>`
        if some_rx =~ x                       # if the email looks good,
          value_if_ok[ x.downcase ]           # we weirdly downcase it
        else
          y << "i hate this email."           # write errmsgs like this
        end                                   #
        nil                                   # result never matters!
      end
    end

The above lets us focus on what normalization means for the particular
field, and insulates us from both how the data is stored and how
we are wired for eventing.

(note: the weird order of arguments that amounts to
[ <no>, <input-value>, <yes> ] stems from the fact that we like result procs
usually to go at the end, by we like `y` yielders to go always at the
beginning.)
