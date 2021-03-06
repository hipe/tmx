module Skylab::Human

  module NLP

    module EN

      class << self

        def [] i
          @method[ i ]
        end

        def an lemma_x, d=nil
          An_[ lemma_x, d ]
        end

        def both a
          Both__[ a ]
        end

        def s * a
          if a.length.zero?
            S__
          else
            S__[ * a ]
          end
        end
      end  # >>

      An_ = -> do

        initial_vowel_rx = /\A[aeiou]/i

        all_caps_rx = /\A[A-Z]+\z/

        -> lemma_x, d=nil do
          lemma_s = lemma_x.to_s
          if lemma_s.length.nonzero?
            x = S__[ d || 1, initial_vowel_rx =~ lemma_s ? :an : :a ]
            if x && all_caps_rx =~ lemma_s
              x.upcase
            else
              x
            end
          end
        end
      end.call

      # ==

      Oxford_and = -> s_a do
        Oxford_AND_prototype[].with_list( s_a ).say
      end

      Oxford_or = -> s_a do
        Oxford_OR_prototype[].with_list( s_a ).say
      end

      oxford_comma_proto = Lazy_.call do

        EN_::Magnetics::List_via_Items.define do |o|
          o.express_none_by do
            NOTHING_
          end
          o.separator = ', '
        end
      end

      Oxford_AND_prototype = Lazy_.call do

        oxford_comma_proto[].redefine do |o|
          o.final_separator = ' and '
        end
      end

      Oxford_OR_prototype = Lazy_.call do

        oxford_comma_proto[].redefine do |o|
          o.final_separator = ' or '
        end
      end

      S__ = -> do  # tested at #spot1.1

        it_them = [ 'them', 'it' ]

        inflected = {
              a: [ 'no ', 'a ', nil ],  # no birds  / a bird   / birds
             an: [ 'no ', 'an ', nil ],  # no errors / an error / errors
           does: [ 'do', 'does' ],
             es: [ 'es', nil, 'es' ],  # matches / match
          exist: [ 'exist', 'is', 'are' ],
             is: [ 'are', 'is' ],
             it: it_them,
             no: [ 'no ', 'the only ', nil ],
         one_of: [  nil, nil, 'one of '  ],
              s: [ 's', nil ],
             _s: [  nil, 's'  ],  # it requires, they require
           this: [ 'these', 'this' ],
            was: [ 'were', 'was' ],
           them: it_them,
              y: [ 'ies', 'y' ]
          }

        # for the above rows that have two cels, if it's a count of zero,
        # use the first cel. if it's a count of one, use the second cel.
        # otherwise use the first cel:

        ( norm_for_two = { 0 => 0, 1 => 1 } ).default = 0

        # for the above rows that hav three cels, if it's a count of zero
        # or one, do as above; otherwise use the *third* (last) cel.

        ( norm_for_three = { 0 => 0, 1 => 1 } ).default = 2

          # rows that have three columns, the default cel to use is the 3rd

        # (see #history-A.1 about the next line below
        -> ( lengthable_x, row_sym=:s ) do

          d = Try_convert_to_length__[ lengthable_x ]
          if d

            row = inflected.fetch row_sym
            if 2 == row.length
              row.fetch norm_for_two[ d ]
            else
              row.fetch norm_for_three[ d ]
            end
          end
        end
      end.call

      Both__ = -> lengthable_x do
        d = Try_convert_to_length__[ lengthable_x ]
        if 2 == d
          BOTH__
        end
      end

      BOTH__ = "both#{ SPACE_ }".freeze

      Try_convert_to_length__ = -> x do
        if x.respond_to? :zero?  # was ::Numeric === x
          x
        else
          x.length
        end
      end

      -> do

        i_a = [] ; p_a = []

        o = -> do
          o_ = -> i, p do
            i_a.push i ; p_a.push p ; nil
          end
          class << o_
            alias_method :[]=, :call
          end
          o_
        end.call

        o[ :an ] = -> s, d=nil do
          s_ = An_[ s, d ]
          if s_
            "#{ s_ }#{ s }"
          else
            s
          end
        end

        o[ :s ] = S__

        @method = ::Struct.new( * i_a ).new( * p_a )

      end.call

      Association_via_symbol_ = -> sym do  # kind of hiding here
        Require_fields_lib_[]
        Field_::SimplifiedName.new sym do end
      end

      AND___ = ' and '.freeze

      COMMA___ = ', '.freeze

      EN_ = self  # do not use `Here_` anywhere in [hu]. this is shorter.
    end  # EN
  end
end
# #history-A.1 (can be temporary) help the ragel parser with parens. see [#bs-042.3.2]
