module Skylab::Zerk

  class InteractiveCLI::View_Maker_Maker___

    class << self
      private :new
    end  # >>

    def initialize
      @_compound_frame_view_controller = nil
      @_location_view_controller = nil
      @_primitive_frame_view_controller = nil
    end

    define_singleton_method :instance, ( Lazy_.call do
      new.freeze
    end )

    def compound_frame= x
      _receive :"@_compound_frame_view_controller", x
    end

    def common_compound_frame
      View_Controllers_::Compound_Frame.common_instance
    end

    def location= x
      _receive :"@_location_view_controller", x
    end

    def common_location
      View_Controllers_::Location.common_instance
    end

    def primitive_frame= x
      _receive :"@_primitive_frame_view_controller", x
    end

    def common_primitive_frame
      View_Controllers_::Primitive_Frame.common_instance
    end

    def _receive ivar, x

      # to this point at least we store this input as though a distinction
      # might be made between the user having not set a value and the user
      # having set a false-ish value. to be able to hold this distinction
      # in a single variable, we wrap it as a [#ca-004] "known known".
      # (if a value is known to be `nil` or known to be `false` it is still
      # a known known.) :#thread-three

      instance_variable_set ivar, Callback_::Known_Known[ x ]
      x
    end

    attr_accessor(
      :custom_tree,
    )

    def make_view_maker stack, rsx
      View_Controllers_::Frame.new(
        stack,
        rsx,
        @_compound_frame_view_controller,
        @_location_view_controller,
        @_primitive_frame_view_controller,
      )
    end
  end
end