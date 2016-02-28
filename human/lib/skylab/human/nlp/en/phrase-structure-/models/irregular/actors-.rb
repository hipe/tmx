module Skylab::Human

  module NLP::EN::Phrase_Structure_

    module Models::Irregular

      Actors_ = ::Module.new

      class Actors_::Inflect  # [#039]

        Callback_::Actor.call self, :properties,

          :y,
          :exponent_state,
          :irregular_form_stream

        def execute

          _st = __reduce_forms @exponent_state, @irregular_form_stream

          s_a = []
          seen_h = {}

          _st.each do | form |
            s = form.surface_string
            seen_h[ s ] and next
            seen_h[ s ] = true
            s_a.push s
          end

          if 1 == s_a.length  # #optimization
            @y << s_a.fetch( 0 )
          else
            # zero or many
            EN_::Oxford_OR_prototype[].with_list( s_a ).express_words_into @y
          end

          @y
        end

        def __reduce_forms and_a, form_st

          # given a "form stream" and a "constituency" of exponents (a set of
          # one or more particular grammatical categories each with one
          # particular exponent value); reduce the form stream: a new stream is
          # produced whose each item is a form that matches this constituency.
          # (wayy more at #miranda-july.)

          form_st.reduce_by do | form |

            yes = true
            and_a.each do | ( cat_sym, exp_sym ) |
              x = form.send cat_sym
              x or next
              exp_sym == x and next
              yes = false
              break
            end
            yes
          end
        end
      end
    end
  end
end
