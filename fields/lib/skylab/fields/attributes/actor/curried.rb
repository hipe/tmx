module Skylab::Fields

  class Attributes

    module Actor::Curried  # ancient experiment. perhaps #feature-island

      class << self

        def backwards_curry__ cls, a, & x_p

          sess = cls.new( & x_p )
          sess.extend Curried_Instance_Methods__
          sess._init_instance_as_curry
          sess._process_args_backwards_as_curry a
          sess
        end

        def curry__ cls, x_a, & x_p

          sess = cls.new( & x_p )
          sess.extend Curried_Instance_Methods__
          sess._init_instance_as_curry
          sess._store_iambic_as_curry x_a
          sess
        end
      end  # >>

      module Curried_Instance_Methods__

        def backwards_curry
          -> * a, & x_p do
            otr = dup
            otr.extend Curried_Instance_Methods__
            otr._init_dup_as_curry( & x_p )
            otr._process_args_backwards_as_curry a
            otr
          end
        end

        def curry_with * x_a, & x_p
          otr = dup
          otr.extend Curried_Instance_Methods__
          otr._init_dup_as_curry( & x_p )
          otr._store_iambic_as_curry x_a
          otr
        end

        def _init_dup_as_curry & oes_p
          if oes_p
            @_oes_p_ = oes_p
          end
          @_remainder_box = @_remainder_box.dup
          NIL_
        end

        def _init_instance_as_curry
          @_remainder_box = self.class::ATTRIBUTES.ivars_box_.dup
          NIL_
        end

        def _process_args_backwards_as_curry a

          full_bx = self.class::ATTRIBUTES.ivars_box_
          rema_bx = @_remainder_box

          deld_sym_a = []
          delta = rema_bx.length - 1

          a.each_with_index do |x, d|
            sym = rema_bx.name_at_position delta - d
            deld_sym_a.push sym
            instance_variable_set full_bx.fetch( sym ), x
          end

          rema_bx.algorithms.delete_multiple deld_sym_a

          NIL_
        end

        def _store_iambic_as_curry x_a

          full_bx = self.class::ATTRIBUTES.ivars_box_.h_
          rema_bx = @_remainder_box

          x_a.each_slice 2 do |k, x|

            if rema_bx.h_.key? k
              rema_bx.remove k  # if it's there. it's OK if it's not
            end

            instance_variable_set full_bx.fetch( k ), x
          end

          NIL_
        end

        def [] * a, & x_p
          otr = dup
          otr.extend Curried_Call_Instance_Methods__
          otr._call_as_curry_via_arglist a, & x_p
        end

        def call * a, & x_p  # same as above
          otr = dup
          otr.extend Curried_Call_Instance_Methods__
          otr._call_as_curry_via_arglist a, & x_p
        end

        def with * x_a, & x_p
          otr = dup
          otr.extend Curried_Call_Instance_Methods__
          otr.__call_as_curry_via_iambic x_a, & x_p
        end
      end

      module Curried_Call_Instance_Methods__

        def _call_as_curry_via_arglist a, & oes_p

          if oes_p
            @_oes_p_ = oes_p
          end

          full_bx = self.class::ATTRIBUTES.ivars_box_.h_
          rb = remove_instance_variable :@_remainder_box

          a.each_with_index do |x, d|
            _sym = rb.name_at_position d
            instance_variable_set full_bx.fetch( _sym ), x
          end

          execute
        end

        def __call_as_curry_via_iambic x_a, & oes_p
          if oes_p
            @_oes_p_ = oes_p
          end
          remove_instance_variable :@_remainder_box
          full_bx = self.class::ATTRIBUTES.ivars_box_.h_
          x_a.each_slice 2 do |k, x|
            instance_variable_set full_bx.fetch( k ), x
          end
          execute
        end
      end
    end
  end
end
