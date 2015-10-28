module Skylab::Brazen

  module Autonomous_Component_System

    module Modalities::JSON::When_

      module Extra

        def self.[] h, sess

          sess.on_event_selectively.call :error, :extra_properties do

            p_a = sess.context_string_proc_stack

            _p = -> do
              if p_a
                p_a.reduce [] do | m, p |
                  m << calculate( & p )
                end.join SPACE_
              end
            end

            Home_::Property::Events::Extra.new_with(
              :name_x_a, h.keys,
              :lemma, 'element',
              :context_prepositional_phrase_proc, _p,
            )
          end
        end
      end
    end
  end
end
