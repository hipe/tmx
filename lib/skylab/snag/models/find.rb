module Skylab::Snag

  class Models::Find  # see [#032] - see if we can unify find commands ..

    def initialize paths, pattern, names
      ech = -> x { ! x.respond_to?( :each ) and "each? - #{ x.inspect }" }
      s_a = [ -> { ech[ paths ] },
              -> { ech[ names ] },
              -> { ! pattern.respond_to?( :ascii_only? ) and "pattern?" }
      ].reduce( [] ) do |m, p|
        s = p[] and m.push s ; m
      end
      s_a.length.zero? or raise ::ArgumentError, s_a * ' - '
      @names = names ; @paths = paths ; @pattern = pattern
      freeze
    end

    def command yes, no
      a =
      [  method( :names_reason ),
         method( :paths_reason ),
         method( :pattern_reason )
      ].reduce( [] ) do |m, p|
        ( e = p[] ) ? m << e : m
      end
      if a.length.nonzero? then no[ a * ' - ' ] else
        Snag_::Library_::Shellwords || nil
        y = [ "find #{ @paths.map(& :shellescape ) * SPACE_ }" ]
        y << "\\( #{@names.map { |n| "-name #{ n.shellescape }"} * ' -o '} \\)"
        y <<
         "-exec grep --line-number --with-filename #{@pattern.shellescape} {} +"
        yes[ y * SPACE_ ]
    # find lib/skylab/snag -name '*.rb' -exec grep --line-number '@t0d0\>' {} +
      end
    end

    nothing = -> { }

    # for each :foo make a `foo_reason` that results in nil iff valid,
    # else string with a failure reason *sentence phrase*.

    [ :names, :paths, :pattern ].each do |m|
      define_method :"#{ m }_reason" do
        send m, nothing, -> predicate { "#{ m } #{ predicate }" }
      end
    end

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

    def to_phrasal_noun_modifier_event  # (was [#029])
      Snag_::Model_::Event.inline(
          :find_phrasal_noun_modifier, :find, self ) do |y, o|
        my = o.find

        e = -> sym do
          -> msg do
            self._COVER_ME  # #todo cover reporting errors in the find struct
            y << "with #{ sym } #{ omg "which #{ msg }" }"
          end
        end

        val = method :val

        my.paths -> p { y << "in #{ and_ p.map(& val ) }" }, e[ :paths ]

        my.names -> n { y << "named #{ or_ n.map(& val ) }" }, e[ :names ]

        my.patrn -> p { y << "with the pattern #{ val[ p ] }" }, e[ :pattern ]

        nil
      end
    end
  end
end
