module Skylab::CodeMetrics

      class CLI::Mutate_Front_and_Back_Properties___

        attr_writer(
          :extmod,
          :mutable_back_props,
          :mutable_front_props,
        )

        def add_additional_properties * x_a

          empty_module  = ::Module.new

          Home_.lib_.fields::Entity.call_by do |sess|
          sess.arglist = x_a
          sess.block = nil
          sess.client = empty_module
          sess.extmod = @extmod
          end

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
