module Skylab::Human

  module NLP

    module EN

      class << self

        def [] i
          @method[ i ]
        end

        def an lemma_x, d=nil
          An__[ lemma_x, d ]
        end

        def both a
          Both__[ a ]
        end

        # ~ begin

        def expression_frame_for * x_a
          expression_frame_via_iambic x_a
        end

        def expression_frame_via_iambic x_a
          __expression_frame_collection.expression_frame_via_iambic x_a
        end

        def __expression_frame_collection
          @___exp_fr_col ||= __build_EFC
        end

        def __build_EFC
          NLP_::Expression_Frame::Models::Collection.new_via_module(
            EN_::Expression_Frames___ )
        end

        # ~ end

        def oxford_comma * a
          d = a.length
          if d.zero?
            Oxford_comma__
          else
            @method[ :oxford_comma ][ * a ]
          end
        end

        def portable_list_phrase
          EN_::Idiomization_::Models::Portable_List_Phrase
        end

        def s * a
          if a.length.zero?
            S__
          else
            S__[ * a ]
          end
        end

        def sentence_string_head_via_words s_a
          NLP::Expression_Frame.sentence_string_head_via_words s_a
        end
      end  # >>

      An__ = -> do

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

      Oxford_comma__ = -> sep, ult, a do

        y = Callback_::Oxford_comma_into[ [], a, ult, sep ]
        if y.length.nonzero?
          y * EMPTY_S_
        end
      end

      S__ = -> do

        inflected = {
              a: [ 'no ', 'a ', nil ],  # no birds  / a bird   / birds
             an: [ 'no ', 'an ', nil ],  # no errors / an error / errors
           does: [ 'do', 'does' ],
             es: [ 'es', nil, 'es' ],  # matches / match
          exist: [ 'exist', 'is', 'are' ],
             is: [ 'are', 'is' ],
             no: [ 'no ', 'the only ', nil ],
         one_of: [  nil, nil, 'one of '  ],
              s: [ 's', nil ],
             _s: [  nil, 's'  ],  # it requires, they require
           this: [ 'these', 'this' ],
            was: [ 'were', 'was' ],
           them: [ 'them', 'it' ],
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

        -> lengthable_x, row_sym=:s do

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
          s_ = An__[ s, d ]
          if s_
            "#{ s_ }#{ s }"
          else
            s
          end
        end

        o[ :oxford_comma ] = -> a, ult=AND___, sep=COMMA___ do
          Oxford_comma__[ sep, ult, a ]
        end

        o[ :s ] = S__

        @method = ::Struct.new( * i_a ).new( * p_a )

      end.call

      AND___ = ' and '.freeze

      COMMA___ = ', '.freeze

      EN_ = self

      Autoloader_[ Expression_Frames___ = ::Module.new, :boxxy ]

    end  # EN
  end
end
