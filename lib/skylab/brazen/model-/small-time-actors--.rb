module Skylab::Brazen

  class Model_

    module Small_Time_Actors__

      class When_expected_datastore_not_indicated  # :+[#035] should probably not be UI-level

        Actor_[ self, :properties,
          :controller ]

        def execute

          label_s = caller_locations( 5, 1 ).first.label
          /(?:\b|_)entity(?:\b|_)/ =~ label_s and lbl_s = label_s

          _ev = build_not_OK_event_with :method_not_implemented,
              :model_class, @controller.class, :lbl, lbl_s do |y, o|

            y << "the #{ val o.model_class.node_identifier.full_name_i.id2name } #{
             }model does not indicate a #{ val :persist_to } model and so has #{
              }no strategy to fall back on for this persist-related operation."

            if o.lbl
              _s = "#{ o.model_class }::#{ o.lbl }"
              y << "either indicate a #{ val :persist_to } or #{
               }implement #{ val _s }"
            end
          end

          @controller.receive_event _ev
          nil
        end
      end
    end
  end
end
