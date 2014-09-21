module Skylab::Callback

  module Actor

    module Curried__

      module Module_Methods

        def accept_arglist_for_curry preset_arglist
          bx = dup_curry_box
          bx_ = actor_property_box_for_arglist
          reverser = bx_.length - 1
          preset_arglist.each_with_index do |x, d|
            bx.add bx_.at_position( reverser - d ), x
          end
          acpt_bx_for_curry bx ; nil
        end

        def accept_iambic_for_curry x_a
          ivar_bx = const_get BX_
          bx = dup_curry_box
          x_a.each_slice 2 do |i, x|
            bx.add ivar_bx.fetch( i ), x
          end
          acpt_bx_for_curry bx ; nil
        end

      private

        def dup_curry_box
          if const_defined? CONST__
            const_get( CONST__ ).dup
          else
            Box.new
          end
        end

        def acpt_bx_for_curry _CURRY_BX
          arg_box = actor_property_box_for_arglist
          _ARG_BX = Box.new
          arg_box.each_pair do |i, ivar|
            _CURRY_BX.has_name ivar and next
            _ARG_BX.add i, ivar
          end
          define_singleton_method :actor_property_box_for_arglist do
            _ARG_BX
          end
          const_set CONST__, _CURRY_BX ; nil
        end
      end

      module Instance_Methods

      private

        def process_arglist_fully a
          init_curried_presets
          super
        end

        def process_iambic_fully x_a
          init_curried_presets
          super
        end

        def init_curried_presets
          self.class.const_get( CONST__ ).each_pair do |i, x|
            instance_variable_set i, x
          end ; nil
        end
      end

      CONST__ = :ACTOR_CURRIED_PROPERTY_BOX___
    end
  end
end
