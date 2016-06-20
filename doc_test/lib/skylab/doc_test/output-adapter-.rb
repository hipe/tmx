module Skylab::DocTest

  module OutputAdapter_  # :[#004].

    # (will rewrite)

    # (when view controller, was [#005])

      Event_for_Wrote_ = Common_::Event.prototype_with :wrote,

        :is_known_to_be_dry, false,
        :bytes, nil,
        :line_count, nil,
        :ok, nil do | y, o |

          y << " done (#{ o.line_count } line#{ s o.line_count }, #{
            }#{ o.bytes }#{ ' (dry)' if o.is_known_to_be_dry } bytes)."
        end

  end
end
# +:#posterity: multiple early versions of stream via array, param lib
