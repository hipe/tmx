module Skylab::Callback

  module Actor

    module Curried__

      module Instance_Methods

        include Call_Methods_

        def backwards_curry

          # this is for currying an already curried instance ([ba])

          super
        end

        def curry_with * x_a

          # ditto

          super
        end

        def process_arglist_fully_as_rcurry_ xx_a

          bx_ = remainder_box_
          del_i_a = []
          delta = bx_.length - 1

          xx_a.each_with_index do | x, d |
            sym = bx_.name_at_position delta - d
            del_i_a.push sym
            instance_variable_set bx_.fetch( sym ), x
          end

          bx_.algorithms.delete_multiple del_i_a

          nil
        end

        def process_iambic_fully_as_curry_ x_a

          bx = formal_fields_ivar_box_for_read_
          bx_ = remainder_box_
          o = bx_.algorithms

          x_a.each_slice 2 do |i, x|

            o.if_has_name i do
              bx_.remove i
            end

            instance_variable_set bx.fetch( i ), x
          end

          nil
        end

        def new & edit_p  # #hook-out for Call_Methods_
          otr = dup
          _REMAINDER_BOX = remainder_box_  # this one is not a dup
          otr.define_singleton_method :formal_fields_ivar_box_for_read_ do
            _REMAINDER_BOX
          end
          otr.instance_exec( & edit_p )
          otr
        end


      end
    end
  end
end
