module Skylab::CodeMetrics

      class CLI::Mutate_Front_and_Back_Properties___

        attr_writer(
          :extmod,
          :mutable_back_props,
          :mutable_front_props,
        )

        def add_additional_properties * x_a

          lib = Home_.lib_.brazen

          empty_module  = ::Module.new
          sess = lib::Entity::Session.new
          sess.arglist = x_a
          sess.block = nil
          sess.client = empty_module
          sess.extmod = @extmod
          sess.execute

          foz = empty_module.properties

          mfp = @mutable_front_props
          mbp = @mutable_back_props

          foz.each_value do | prp |

            k = prp.name_symbol
            mfp.add k, prp
            mbp.add k, prp
          end

          NIL_
        end
      end
    # -
  # -
end
