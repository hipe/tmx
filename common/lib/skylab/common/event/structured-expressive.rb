module Skylab::Common

  class Event::StructuredExpressive

    # (moved here from [ta]. won't put it next to the others, it's too deep)

      # this is a class that makes classes, similar to platform ::Struct.
      # whereas we construct a ::Struct subclass by passing it a list of
      # symbols (representing its members), here we pass it a list of members
      # PLUS one additional argument representing the "expression proc".
      #
      # so build the class with N (one or more) symbols and one proc:
      #
      #     Wing_Wang_Predicate = _Subject.new :wing, :wang, -> do
      #       "wing is: #{ @wing }, wang: #{ @wang }"
      #     end
      #
      # then you can construct an instance of the expression in the same way
      # that you would construt a struct instance, passing values for members:
      #
      #     expr = Wing_Wang_Predicate.new 'DING', 'DANG'
      #
      # if we want we can read those member values with readers:
      #
      #     expr.wing  # => 'DING'
      #     expr.wang  # => 'DANG'
      #
      # the members are stored as ivars. hackishly, we can see this in
      # action by evaluating our expression proc in the context of our
      # expression object:
      #
      #     expr.instance_exec( & expr.expression_proc )  # => "wing is: DING, wang: DANG"
      #

      # alternately you can define the proc to take arguments:
      #
      #     ArgTaker = _Subject.new :a, :b, -> a, b { "#{ a } + #{ b }" }
      #
      # when the expression proc has been defined in this manner,
      # call `string_via_express` to produce an expression string:
      #
      #     _expr = ArgTaker[ "one", "two" ]  # same as `.new(..)`
      #
      #     _expr.string_via_express  # => "one + two"

      # even better, you can define the articulation class with only a
      # proc (actually a block) and it will work as is (probably) expected:
      #
      #     EvenBetter = _Subject.new do |a, b|
      #       "#{ a } + #{ b }"
      #     end
      #
      # (as always) we can use `members` to see what the formal members
      # are. (we have used platform proc reflection to get those names):
      #
      #     EvenBetter.members   # => [ :a, :b ]
      #
      # and we can express like the "arg taker" form above:
      #
      #     _expr = EvenBetter.new "one", "two"
      #     _expr.string_via_express  # => "one + two"

        class << self
          alias_method :orig_new, :new
        end

        def self.new * i_a, & procedure

          if ! procedure
            procedure = i_a.pop
          end

          if i_a.length.zero?
            i_a = procedure.parameters.map( & :last )
          end

          i_a.freeze

          ::Class.new( self ).class_exec do
            class << self
              alias_method :new, :orig_new
              alias_method :[], :new
            end
            const_set :MEMBER_A_, i_a
            const_set :IVAR_A_, i_a.map { |i| :"@#{ i }" }.freeze
            const_set :IVAR_H_, ::Hash[ i_a.zip self::IVAR_A_ ].freeze
            const_set :PROC_, procedure
            def initialize * x_a
              ivar_a = self.ivar_a
              ( 0 ... (( len = x_a.length )) ).each do |idx|
                instance_variable_set ivar_a.fetch( idx ), x_a.fetch( idx )
              end
              ( len ... ivar_a.length ).each do |idx|
                instance_variable_set ivar_a.fetch( idx ), nil
              end
              nil
            end
            attr_reader( * i_a )
            self
          end
        end

        class << self

          alias_method :[], :new

          def members
            self::MEMBER_A_
          end
        end  # >>

        def string_via_express
          NIL.instance_exec( * to_a, & expression_proc )
        end

        def express_into_under y, expag
          y << string_via_express_under( expag )
        end

        def string_via_express_under expag
          expag.instance_exec( * to_a, & expression_proc )
        end

        def at * i_a
          i_a.map( & method( :[] ) )
        end

        def members
          self.class.members
        end

        def ivar_a
          self.class::IVAR_A_
        end

        def ivar_h
          self.class::IVAR_H_
        end

        def expression_proc
          self.class::PROC_
        end

        def to_a
          ivar_a.map( & method( :instance_variable_get ) )
        end

    begin

      # because the expression proc is exposed as the ordinary proc that it
      # is, you can evaluate it in any arbitrary context.
      #
      # here we'll define an expression class and what we call an
      # "expression agent":
      #
      #     module My
      #
      #       class ExpressionAgent
      #         def em s
      #           "__#{ s.upcase }__"
      #         end
      #       end
      #
      #       cls = Skylab::Common::Event::StructuredExpressive
      #
      #       ErrorPredicate = cls.new( :name, :value, -> me do
      #         n, v = me.at :name, :value
      #         "#{ n } had a #{ em 'bad' } issue - #{ v }"
      #       end )
      #     end
      #
      # now, when we evaluate the expression proc we'll do it in the context
      # of this "expression agent" (which could be anything). in this way,
      # you can define a formal set of "expression functions" and implement
      # those functions in any arbitrary way in your expression agent,
      # allowing for a bit of dependency injection:
      #
      #     expr = My::ErrorPredicate.new 'I', 'burnout'
      #
      #     _expag = My::ExpressionAgent.new
      #
      #     _s = _expag.instance_exec expr, & expr.expression_proc
      #
      #     _s  # => "I had a __BAD__ issue - burnout"

      # `to_a` is available..
      #
      #     Pair = _Subject.new :up, :down, -> up, down do
      #       "#{ up } and #{ down }"
      #     end
      #
      # ..if for example you wanted to mimic `string_via_express`:
      #
      #     expr = Pair.new 'hi', 'lo'
      #     expr.expression_proc[ * expr.to_a ]  # => 'hi and lo'
      #

      # expression instances have a stupid simple but powerful algorithm
      # for inflection.
      #
      #     module These
      #
      #       o = Skylab::Common::Event::StructuredExpressive
      #
      #       NP = o.new :a, -> a { a * ' and ' }
      #
      #       VP = o.new :tense, :a, -> t, a do
      #         :present == t ? ( 1 == a.length ? 'has' : 'have' ) : 'had'
      #       end
      #     end
      #
      # it's a bit obtuse (i don't understand it today) but it's almost magical:
      #
      #     o = These
      #     vp = o::VP ; np = o::NP
      #
      #     ( np[ [ 'jack' ] ] | vp[ :present ] ).inflect  # => "jack has"
      #
      #     ( np[ %w(Jack Jill) ] | vp[ :present ] ).inflect  # => "Jack and Jill have"
      #
      #     ( np[ %w( Jack ) ] | vp[ :past ] ).inflect  # => "Jack had"

    end
        def | art_x
          Inflection___.new self, art_x
        end

        def [] member_i
          instance_variable_get( ivar_h.fetch member_i )
        end

        def []= member_i, x
          instance_variable_set ivar_h.fetch( member_i ), x
        end

      class Inflection___

        def initialize first, second
          @a = [ first, second ]
        end

        def inflect
          resolve_missing_members
          @a.reduce( [] ) do |m, art|
            (( s = art.string_via_express )) and m << s
            m
          end * SPACE_
        end

      private

        def resolve_missing_members
          provider_h = ::Hash.new { |h, k| h[k] = [] }
            # member_i => provider_idx_a
          missing_a = [ ]  # [ [ provider_idx, member_i ] [..] )
          @a.each_with_index do |art, art_idx|
            member_a = art.members
            art.to_a.each_with_index do |x, idx|
              member_i = member_a.fetch idx
              if x.nil?
                missing_a << [ art_idx, member_i ]
              else
                provider_h[ member_i ] << art_idx
              end
            end
          end
          missing_a.each do |art_idx, member_i|
            needer = @a[ art_idx ]
            provider_h.key? member_i or raise "inflector could not resolve #{
              }'#{ member_i }' for #{ needer.class } - no such member was #{
              }present and non-nil in the other #{ @a.length - 1 } #{
              }articulator(s)."
            1 == (( a = provider_h.fetch member_i )).length or raise "infle#{
              }ction resolution ambiguity, #{ member_i } needed by #{
              }#{ needer.class } was present in #{
              }#{ a.map { |aidx| @a[ aidx ].class } * ' and ' }"
            needer[ member_i ] = @a[ a.fetch( 0 ) ][ member_i ]
          end
          nil
        end
      end
    # -
  end
end
# #history-A: moved here from [ta]
