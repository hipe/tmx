class Skylab::Task
  # ->
    class Eventpoint

      class Expression_

        # this generates a simple articulator class.
        #
        #     _Wing_Wang_Predicate = Subject.
        #       new( :wing, :wang, -> do
        #         "wing is: #{ @wing }, wang: #{ @wang }"
        #       end )
        #
        #     obj = _Wing_Wang_Predicate.new 'DING', 'DANG'
        #
        #     obj.wing  # => 'DING'
        #
        #     obj.wang  # => 'DANG'
        #
        #     obj.instance_exec( & obj.articulation_proc )  # => "wing is: DING, wang: DANG"


        # with `articulate_self` pass the same fields in as arguments
        #
        #     o = Subject.new( :a, :b, -> a, b { "#{ a } + #{ b }" } )
        #     o[ "one", "two" ].articulate_self  # => "one + two"



        # definine the articulator with ony one function:
        #
        #     o = Subject.new do |a, b|
        #       "#{ a } + #{ b }"
        #     end
        #
        #     o[ "one", "two" ].articulate_self  # => "one + two"

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
        end

        def members
          self.class::MEMBER_A_
        end

        def ivar_a
          self.class::IVAR_A_
        end

        def ivar_h
          self.class::IVAR_H_
        end

        def articulation_proc
          self.class::PROC_
        end

        def articulate_self
          instance_exec( * to_a, & articulation_proc )
        end

        define_method :at, & Here_::At_

        def to_a
          ivar_a.map( & method( :instance_variable_get ) )
        end

      # other times you might do clever things with the rendering context
      #
      #     _Error_Predicate = Subject.new(
      #       :name, :val, -> o do
      #         n, v = o.at :name, :val
      #         "#{ n } had a #{ em 'bad' } issue - #{ v }"
      #       end )
      #
      #     err = _Error_Predicate.new 'I', 'burnout'
      #
      #     o = ::Object.new
      #     def o.em s ; "__#{ s.upcase }__" end
      #
      #     exp = "I had a __BAD__ issue - burnout"
      #     ( o.instance_exec err, & err.articulation_proc )  # => exp


      # write your proc signature however you like, e.g use `to_a`
      #
      #     _Art = Subject.new :up, :down, -> up, down do
      #       "#{ up } and #{ down }"
      #     end
      #
      #     p = _Art.new( 'hi', 'lo' )
      #     p.articulation_proc[ * p.to_a ]  # => 'hi and lo'
      #

      # expression sessions have a stupid simple but powerful algorithm for inflection
      #
      #     _NP = Subject[ :a, -> a { a * ' and ' } ]
      #     _VP = Subject[ :tense, :a, -> t, a do
      #       :present == t ? ( 1 == a.length ? 'has' : 'have' ) : 'had'
      #     end ]
      #
      #     ( _NP[ [ 'jack' ] ] | _VP[ :present ] ).inflect  # => "jack has"
      #
      #     ( _NP[ %w(Jack Jill) ] | _VP[ :present ] ).inflect  # => "Jack and Jill have"
      #
      #     ( _NP[ %w( Jack ) ] | _VP[ :past ] ).inflect  # => "Jack had"

        def | art_x
          Inflection___.new self, art_x
        end

        def [] member_i
          instance_variable_get( ivar_h.fetch member_i )
        end

        def []= member_i, x
          instance_variable_set ivar_h.fetch( member_i ), x
        end
      end

      class Inflection___

        def initialize first, second
          @a = [ first, second ]
        end

        def inflect
          resolve_missing_members
          @a.reduce( [] ) do |m, art|
            (( s = art.articulate_self )) and m << s
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
    end
  # -
end
