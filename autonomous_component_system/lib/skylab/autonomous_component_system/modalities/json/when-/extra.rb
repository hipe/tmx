module Skylab::Autonomous_Component_System
  # ->
    module Modalities::JSON::When_

      module Extra

        def self.[] sym_a, sess

          sess.caller_emission_handler_.call :error, :extra_properties do

            _LL = sess.context_linked_list

            _p = -> s_a, ev do

              if _LL

                st = _LL.to_element_stream_assuming_nonsparse

                s_a_ = st.join_into [] do |p|
                  calculate( & p )
                end

                s_a_.reverse!
                s_a.concat s_a_
                s_a
              end
            end

            Require_fields_lib_[]

            _ev = Field_::Events::Extra.with(
              :unrecognized_tokens, sym_a,
              :noun_lemma, 'element',
              :suffixed_prepositional_phrase_context_proc, _p,
            )

            _ev
          end

          NIL_
        end
      end
    end
  # -
end
