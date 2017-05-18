module Skylab::Zerk

  class InteractiveCLI

  class View_Maker_Maker___  # (built by top client)

    class << self
      private :new
    end  # >>

    define_singleton_method :instance, ( Lazy_.call do
      # (this is *not* singleton pattern - it's prototype pattern)
      new.freeze
    end )

    def initialize
      @_compound_frame_view_controller = nil
      @_location_view_controller = nil
      @_primitive_frame_view_controller = nil
    end

    def custom_tree_array_proc= x
      @custom_tree_array_proc__ = x
    end

    def compound_frame= x
      _receive :"@_compound_frame_view_controller", x
    end

    def common_compound_frame
      Here_::Compound_Frame_ViewController___.common_instance
    end

    def location= x
      _receive :"@_location_view_controller", x
    end

    def common_location
      Here_::Location_ViewController___.common_instance
    end

    def primitive_frame= x
      _receive :"@_primitive_frame_view_controller", x
    end

    def common_primitive_frame
      Here_::Atomesque_Frame_ViewController_.common_instance
    end

    def _receive ivar, x

      # to this point at least we store this input as though a distinction
      # might be made between the user having not set a value and the user
      # having set a false-ish value. to be able to hold this distinction
      # in a single variable, we wrap it as a [#ca-004] "known known".
      # (if a value is known to be `nil` or known to be `false` it is still
      # a known known.) :#thread-three

      instance_variable_set ivar, Common_::KnownKnown[ x ]
      x
    end

    def make_view_maker__ event_loop, rsx
      Here_::MainViewController___.new(
        event_loop.method( :top_frame ),
        rsx,
        @_compound_frame_view_controller,
        @_location_view_controller,
        @_primitive_frame_view_controller,
      )
    end

    attr_reader(
      :custom_tree_array_proc__,
    )
  end

  end
end
