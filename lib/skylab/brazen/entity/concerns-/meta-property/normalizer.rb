module Skylab::Brazen

  module Entity

    module Concerns_::Meta_Property

      class Normalizer

        # assume one or more metaproperties with hooks

        def initialize sess

          @_mprp_a = sess.property_class.const_get METAPROPERTIES_WITH_HOOKS_
        end

        def normalize_mutable_property prp  # :+[#087] similar n11n logic

          @_mprp_a.each do | mprp |

            dp = mprp.default_proc
            if dp
              x = prp.send mprp.property_reader_method_name
              if x.nil?
                x = dp.call
                prp.send mprp.property_setter_method_name, x
              end
            end

            bx = mprp.norm_box_
            if bx
              bx.each_value do | norm_p |
                norm_p[ prp, mprp ]
              end
            end
          end

          NIL_
        end
      end
    end
  end
end
