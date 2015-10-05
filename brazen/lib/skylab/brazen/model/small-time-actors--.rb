module Skylab::Brazen

  class Model

    module Small_Time_Actors__

      class When_collection_not_indicated  # :+[#035] should probably not be UI-level

        Actor_.call self, :properties,
          :controller

        def execute
          @label_s = caller_locations( 5, 1 ).first.label
          @controller.maybe_receive_event :error, :method_not_implemented do
            bld
          end
        end

        def bld

          /(?:\b|_)entity(?:\b|_)/ =~ @label_s and lbl_s = @label_s

          build_not_OK_event_with :method_not_implemented,
              :model_class, @controller.class, :lbl, lbl_s do | y, o |

            _s = o.model_class.node_identifier.full_name_symbol.id2name

            y << "the #{ val _s } #{
             }model does not indicate a #{ val :persist_to } model and so has #{
              }no strategy to fall back on for this persist-related operation."

            if o.lbl
              _s = "#{ o.model_class }::#{ o.lbl }"
              y << "either indicate a #{ val :persist_to } or #{
               }implement #{ val _s }"
            end
          end
        end
      end
    end
  end
end
