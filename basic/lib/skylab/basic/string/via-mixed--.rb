module Skylab::Basic

  module String

    class Via_Mixed__  # :[#019] #:+[#hu-002] summarization (trivial)

      # conceptually similar to sending `inspect` to some mystery value
      # but configurable: based on the shape and charactersitics of the
      # value, different callbacks are called effecting ad-hoc behavior
      # for example ellipsifying long strings, formatting floats, etc.
      #
      # middleface: the instance method called `instance` only
      #
      # historical background: the previous olschool implementation was
      # as a simple curry-intentioned 2-arg proc which made hard-coded
      # expression decisions and exposed one configurability: the max
      # width of the output string. the newchool implementation is ..
      #
      # design considerations:
      #
      #   • all aspects of this should be in the context of the performer.
      #     avoid plain old procs because there is a chance that we will
      #     make even shape classification configurable.

      class << self
        private :new
      end

      define_singleton_method :instance, ( Lazy_.call do

        o = new
        o.max_width = A_REASONABLY_SHORT_LENGTH_FOR_A_STRING_

        # (all of the below use attr writers generated at end of file.)

        # ~

        p = -> x, _ do
          x.inspect
        end
        o.on_false = p
        o.on_nil = p
        o.on_moduleish = p
        o.on_nonlong_stringish = p
        o.on_numericish = p
        o.on_true = p
        p = nil

        # ~

        o.on_long_stringish = -> s, o_ do

          _ = String_.ellipsify s, o_.max_width
          o_.on_nonlong_stringish[ _, o_ ]
        end

        simple_rx = /\A[[:alnum:] _]+\z/

        o.on_symbolish = -> sym, _ do

          s = sym.id2name
          if simple_rx =~ s
            "'#{ s }'"
          else
            "'#{ s.inspect[ 1 .. -2 ] }'"  # pretend we are JS, meh
          end
        end

        _qqq = '???'
        o.on_other = -> x, _ do

          if x.respond_to? :class
            "< a #{ x.class } >"
          else
            _qqq
          end
        end

        o.to_proc  # eek - write the ivar before freeze :/
        o.freeze
      end )

      def initialize
        # (hi.)
      end

      def initialize_copy _
        @_as_proc = nil  # note below
      end

      attr_accessor(  # ~ hard-coded configurables
        :max_width,
      )

      # -- invocation

      def call_via_arglist a

        Dispatcher___[ 1 <=> a.length ][ * a, self ]
      end

      Dispatcher___ = {

        -1 => -> d, x, o do
          o_ = o.dup  # a lot of ivars to dup for one call :/
          o_.max_width = d
          o._say_for x
        end,

        0 => -> x, o do
          o._say_for x
        end,

        1 => IDENTITY_

      }.method :fetch

      def to_proc

        # it's crucial that we remember to nilify the below ivar on
        # dup because it is bound to the instance that creates it.
        # also we can't just make a method reflection. it has to be
        # a real proc (so others can use it as their own definition.)

        @_as_proc ||= ___build_proc
      end

      def ___build_proc
        me = self  # because proc used as method definition elsewhere
        -> x do
          me._say_for x
        end
      end

      def _say_for x

        # (this actual invocation method is kept private so that we
        # internalize the choice of whether or not we implement as a
        # traditional session with mutable state. for now, we don't.)

        _cx = ___classify x
        _ivar = _cx.__as_ivar
        _proc = instance_variable_get _ivar
        _ = _proc[ x, self ]
        _
      end

      def ___classify x  # (very likely to expose this)

        if x
          if x.respond_to? :ascii_only?

            if @max_width < x.length
              LONG_STRINGISH___
            else
              NONLONG_STRINISH___
            end

          elsif x.respond_to? :id2name
            SYMBOLISH___

          elsif x.respond_to? :divmod
            NUMERICISH___

          elsif true == x
            TRUE___

          elsif x.respond_to? :included_modules
            MODULEISH___

          else
            OTHER___
          end

        elsif x.nil?
          NIL___

        else
          FALSE___
        end
      end

      # -- the shape model

      class Shape___

        def initialize sym

          # we don't use [#bs-028]#A because (and IFF) the
          # genarated names appear somewhere in this document.

          @_on_foo = :"on_#{ sym }"
        end

        def __as_ivar
          @___as_ivar ||= :"@#{ @_on_foo }"
        end

        attr_reader :_on_foo
      end

      o = -> sym do
        shape = Shape___.new sym
        attr_accessor shape._on_foo
        shape
      end

      FALSE___ = o[ :false ]
      LONG_STRINGISH___ = o[ :long_stringish ]
      MODULEISH___ = o[ :moduleish ]
      NIL___ = o[ :nil ]
      NONLONG_STRINISH___ = o[ :nonlong_stringish ]
      NUMERICISH___ = o[ :numericish ]
      OTHER___ = o[ :other ]
      SYMBOLISH___ = o[ :symbolish ]
      TRUE___ = o[ :true ]
    end
  end
end
