module Skylab::Autonomous_Component_System

  # ->

    module Modalities::JSON::When_

      module Extra

        def self.[] sym_a, sess

          sess.on_event_selectively.call :error, :extra_properties do

            context_x = sess.context_x

            _p = -> s_a, _ev do

              if context_x

                st = context_x.to_element_stream_assuming_nonsparse

                s_a_ = st.reduce_into_by [] do | m, p |

                  m << calculate( & p )
                end

                s_a_.reverse!
                s_a.concat s_a_
                s_a
              end
            end

            Home_.lib_.brazen::Property::Events::Extra.new_with(
              :name_x_a, sym_a,
              :lemma, 'element',
              :suffixed_prepositional_phrase_context_proc, _p,
            )
          end
        end
      end
    end
  # -
end
