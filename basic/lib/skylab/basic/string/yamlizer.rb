module Skylab::Basic

  module String

    class Yamlizer  # for now covered by [sg]  #todo
      # -
        def initialize
          NIL_
        end

        attr_writer :line_downstream

        def register_properties

          a = [] ; h = {}
          p = -> prp, & exp_p do
            a.push prp
            h[ prp.name_symbol ] = exp_p
            NIL_
          end
          p.singleton_class.send :alias_method, :register_property, :call
          yield p
          __init_format a
          @__properties = a
          @__expressers = h

          NIL_
        end

        def __init_format prp_a

          _maxlen = prp_a.reduce 0 do | m, prp |

            d = prp.name.as_slug.length
            m > d ? m : d
          end

          @__fmt = "%-#{ _maxlen }s"

          NIL_
        end

        def << item

          @line_downstream << BAR___

          @__properties.each do | prp |

            x = item.property_value_via_property prp
            if x.nil?
              next  # (alternately we might pass these to the expresser)
            end

            _p = @__expressers.fetch prp.name_symbol

            s = _p[ x ]
            if s
              @line_downstream << "#{ @__fmt % prp.name.as_slug } : #{ s }"
            end
          end
          self
        end

        BAR___ = '---'.freeze
      # -
    end
  end
end
