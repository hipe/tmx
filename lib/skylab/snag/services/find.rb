module Skylab::Snag

  class Services::Find  # [#032] - see if we can unify find commands ..

    #         ~ the point is to make it hard to succeed ~

    # we are playing with a pattern here .. it's weird but i kind of like it:
    #
    # internal state is totally hidden so there are no straightforward
    # attribute readers - NONE. This is designed such that it cannot fail.
    # Its methods are infallible. Every high- and low-level property can only
    # be queried via passing two callbacks, one that is called when the
    # property is valid and one that is called when it is not.
    #
    # The details: the Command object is made up (either virtually or actually)
    # of high-level composite (derivative) properties like the command
    # string, and lower-level constituent properties that .. constitue it,
    # like e.g. the filesystem paths that will go into the command string.
    #
    # At any given time each of these properties is in either a valid
    # or an invalid state (in fact we will probably maintain a frozen,
    # immutable state). The state of validity *must* be queried as
    # part of querying for the property - it is not possible simply to
    # send a message requesting the value of the property, just as one
    # does not simply walk in and out of mordor.
    #
    # Never ever do we result in an invalid value, but as such never ever can
    # we deterministicly expect that a method call will always result in
    # a valid value. Each accessor method ("") must be able to follow one of
    # two paths, one when valid and one when not.
    #
    # Each accessor for each property then follows a yes/no form
    # where it takes two corresponding callbacks as its two arguments.
    # If the property is in a valid state, `yes` is called (either with
    # a dupe of the property or with nothing, based on whether the arity
    # of `yes` was 1).
    #
    # If the property (either because of something intrinsic or something
    # extrinsic in the state of the host object) is invalid, `no` will
    # be called, always with exactly 1 string explaining the failure reason.
    #

    def command yes, no
      a =
      [  method( :names_reason ),
         method( :paths_reason ),
         method( :pattern_reason )
      ].reduce( [] ) do |m, p|
        ( e = p[] ) ? m << e : m
      end
      if a.length.nonzero? then no[ a * ' - ' ] else
        Snag::Services::Shellwords || nil
        y = [ "find #{ @paths.map(& :shellescape ) * ' ' }" ]
        y << "\\( #{@names.map { |n| "-name #{ n.shellescape }"} * ' -o '} \\)"
        y <<
         "-exec grep --line-number --with-filename #{@pattern.shellescape} {} +"
        yes[ y * ' ' ]
    # find lib/skylab/snag -name '*.rb' -exec grep --line-number '@t0d0\>' {} +
      end
    end

    nothing = result = nil

    # for each :foo make a `foo_reason` that results in nil iff valid,
    # else string with a failure reason *sentence phrase*.

    [ :names, :paths, :pattern ].each do |m|
      define_method "#{ m }_reason" do
        send m, nothing, -> predicate { "#{ m } #{ predicate }" }
      end
    end

    nothing = -> { }

    result = -> x { x }

    nonzero_length = nil  # scope

    define_method :names do |yes, no|          # the validity for `names` is
      nonzero_length[ @names, yes, no ]  # defined as..
    end

    nonzero_length = -> x, yes, no do
      if x.length.nonzero?
        if 1 == yes.arity
          yes[ x.map(& :dup ) ]
        else
          yes[]
        end
      else
        no[ "is zero length" ]
      end
    end

    define_method :paths do |yes, no|          # and so on..
      nonzero_length[ @paths, yes, no ]
    end

    trueish = nil  # scope

    define_method :pattern do |yes, no|
      trueish[ @pattern, yes, no ]
    end

    alias_method :patrn, :pattern  # ocd

    trueish = -> x, yes, no do
      if x
        if 1 == yes.arity
          yes[ x.dup ]
        else
          yes[]
        end
      else
        no[ "does not exist." ]
      end
    end

    #        ~ couresy & rendering ~

    def prepositional_phrase_under client  # like [#029]
      my = self
      client.instance_exec do
        y = [ ]

        e = -> sym do
          -> msg do
            y << "with #{ sym } #{ omg "which #{ msg }" }"
          end
        end

        val = method :val

        my.paths -> p { y << "in #{ and_ p.map(& val ) }" }, e[ :paths ]

        my.names -> n { y << "named #{ or_ n.map(& val ) }" }, e[ :names ]

        my.patrn -> p { y << "with the pattern #{ val[ p ] }" }, e[ :pattern ]

        y * ' '
      end
    end

  protected

    def initialize paths, names, pattern
      ech = -> x { "each? - #{ x.inspect }" if ! x.respond_to? :each }
      [ -> { ech[ paths ] },
        -> { ech[ names ] },
        -> { "pattern? #{ pattern.class }" if ! ( ::String === pattern ) }
      ].reduce( [] ) do |m, p|
        ( e = p[] ) ? m << e : m
      end.tap do |a|
        if a.length.nonzero?
          raise ::ArgumentError, e * ' - '
        else
          @paths, @names, @pattern = paths, names, pattern
          freeze  # BOOM
        end
      end
    end
  end
end
