module Skylab::TestSupport

  module DocTest

    module Intermediate_Streams_

      module Models_::Predicate_Expressions

        class << self

          def match line
            RX__.match line
          end

          def expression_via_matchdata md
            pre = md.pre_match
            post = md.post_match
            post.chomp!
            Fat_Comma_Proto_Predicate__.new pre, post
          end
        end

        RX__ = /[[:space:]]*#[ ]?=>[[:space:]]*/

        class Raw_Line
          class << self
            alias_method :[], :new
          end

          def initialize s
            @string = s
          end

          attr_reader :string

          def members
            [ :string, :expression_symbol ]
          end

          def expression_symbol
            :raw_line
          end

        end

        class Fat_Comma_Proto_Predicate__

          def initialize * a
            @lhs, @rhs = a
          end

          attr_reader :lhs, :rhs

          def members
            [ :lhs, :rhs, :expression_symbol ]
          end

          def expression_symbol
            :proto_predicate
          end
        end

  if false

  class Templos__::Predicates  # a box module and a class.

    def << line
      @add[ line ]
      self
    end

    def add line
      @add[ line ]
    end

    def flush
      @flush.call
    end

    def initialize altered_line=nil, unaltered_line=nil
      altered_line ||= begin
        a = [ ]
        @flush = -> do
          r = a ; a = [ ] ; r
        end
        -> line { a << line ; false }
      end
      unaltered_line ||= altered_line
      y = ::Enumerator::Yielder.new( & altered_line )
      @add = -> line do
        idx = line.index SEP_ ; matched = nil
        if idx   # magic separator hack - "# =>" becomes:
          lef = line[ 0 .. idx - 1 ].strip
          rig = line[ idx + SEP_.length .. -1 ].strip
          matched = self.class.each.reduce nil do |_, p|
            # module as switch statement [#ba-018]
            p[ y, lef, rig ] and break true
          end
        end
        matched or unaltered_line[ line ] && false
      end
    end

    def self.each
      if const_defined? :EACH_, true then const_get :EACH_, true else
        const_set :EACH_, constants.map { |i| const_get i, false }.freeze  # !
      end
    end
  end

  Templos__::Predicates::SHOULD_RAISE_ = -> do
    # e.g "NoMethodError: undefined method `wat` .."
    cnst = '[A-Z][A-Za-z0-9_]'
    hack_rx = /\A[ ]*
      (?<const> #{ cnst }*(?:::#{ cnst }*)* ) [ ]* : [ ]+
      (?:
        (?<fullmsg> .+ [^.] \.? ) |
        (?: (?<msgfrag> .* [^. ] ) [ ]* \.{2,} )
      ) \z
    /x

    -> y, lef, rig do
      hack_rx.match rig do |md|
        const, fullmsg, msgfrag = md.captures
        _rx = if fullmsg
          "\\A#{ ::Regexp.escape fullmsg }\\z".inspect
        else
          "\\A#{ ::Regexp.escape msgfrag }".inspect
        end
        y << '-> do'
        y << "  #{ lef }"
        y << "end.should raise_error( #{ const },"
        y << "             ::Regexp.new( #{ _rx } ) )"
        true  # important
      end
    end
  end.call

  Templos__::Predicates::SHOULD_EQL_ = -> y, lef, rig do
    y << "#{ lef }.should eql( #{ rig } )"
    true  # important
  end
  end

      end
    end
  end
end
