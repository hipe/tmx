module Skylab::Zerk::TestSupport

  class Non_Interactive_CLI::HelpScreenSimplePool

    # the fifth of the [#br-106] facilities, this is :[#054.2]

    # it is not a general replacement for the others

    # it is a deep hack

    # x.

    # blank lines not supported

    # extremely hacked so it is only applied once per defintion

    class << self
      alias_method :define, :new
      undef_method :new
    end  # >>

    # -
      def initialize
        yield self
        @_once = :__first_once
      end

      def mandatory_pool * sym_a
        @_mandatory_pool = ::Hash[ sym_a.map { |sym| [ sym, nil ] } ].freeze
        NIL
      end

      def once
        send @_once
      end

      def __first_once
        @_once = :__subsequent_once
        Spy___.new @_mandatory_pool
      end

      def __subsequent_once
        NO_OP___
      end
    # -
    # ==

    class Spy___

      def initialize h
        @_mandatory_pool = h.dup
        @_regex = /\A[ \t]+(?:-(?<moniker>[a-z-]+))?/

        @proc = method :__see
      end

      def __see line
        md = @_regex.match line
        moni = md[ :moniker ]
        if moni
          @_mandatory_pool.delete moni.gsub( DASH_, UNDERSCORE_ ).intern
        end
        NIL
      end

      def close
        if @_mandatory_pool.length.nonzero?
          __fail
        end
      end

      def __fail
        _ks = @_mandatory_pool.keys
        _s_a = _ks.map do |sym|
          buffer = DASH_.dup
          buffer << sym.id2name.gsub( UNDERSCORE_, DASH_ )
          buffer
        end
        ::Kernel.fail "missing in help screen: (#{ _s_a * ', ' })"
      end

      attr_reader(
        :proc,
      )
    end

    # ==

    module NO_OP___ ; class << self

      # on subsequent invocations don't bother parsing every string, etc.

      def proc
        MONADIC_EMPTINESS_
      end

      def close
        NOTHING_
      end

    end ; end

    # ==

    DASH_ = '-'
    UNDERSCORE_ = '_'

    # ==
  end
end
# #born as the fifth in a strain
