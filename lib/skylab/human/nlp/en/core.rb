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

        def oxford_comma * a
          d = a.length
          if d.zero?
            Oxford_comma__
          else
            @method[ :oxford_comma ][ * a ]
          end
        end

        def s * a
          if a.length.zero?
            S__
          else
            S__[ * a ]
          end
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

        if a.length.nonzero?

          st = Callback_::Polymorphic_Stream.via_array a.reverse

          x = st.gets_one

          if st.no_unparsed_exists
            x
          else
            y = [ x, ult, st.gets_one ]

            while st.unparsed_exists

              y.push sep, st.gets_one
            end
            y.reverse!
            y * EMPTY_S_
          end
        end
      end

      AND__ = ' and '.freeze ; COMMA__ = ', '.freeze

      S__ = -> do

        inflected = {
              a: [ 'no ', 'a ' ],  # no birds  / a bird   / birds
             an: [ 'no ', 'an ' ],  # no errors / an error / errors
           does: [ 'do', 'does', 'do' ],
             es: [ 'es', nil, 'es' ],  # matches / match
          exist: [ 'exist', 'is', 'are' ],
             is: [ 'are', 'is', 'are' ],
             no: [ 'no ', 'the only ' ],
         one_of: [  nil, nil, 'one of '  ],
              s: [ 's', nil, 's' ],
             _s: [  nil, 's'  ],  # it requires, they require
           this: [ 'these', 'this', 'these' ],
            was: [ 'were', 'was', 'were' ],
           them: [ 'them', 'it', 'them' ],
              y: [ 'ies', 'y', 'ies' ]
          }

        ( norm = { 0 => 0, 1 => 1 } ).default = 2

        -> lengthable_x, i=:s do
          d = Try_convert_to_length__[ lengthable_x ]
          if d
            inflected.fetch( i )[ norm[ d ] ]
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

        o[ :oxford_comma ] = -> a, ult=AND__, sep=COMMA__ do
          Oxford_comma__[ sep, ult, a ]
        end

        o[ :s ] = S__

        @method = ::Struct.new( * i_a ).new( * p_a )

      end.call

      EN_ = self

      Autoloader_[ Expression_Frames___ = ::Module.new, :boxxy ]

    end  # EN
  end
end
