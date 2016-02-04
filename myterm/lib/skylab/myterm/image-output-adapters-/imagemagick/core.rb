module Skylab::MyTerm

  class Image_Output_Adapters_::Imagemagick  # (notes in [#003], [#004])

    def initialize svc
      @_svc = svc
    end

    # -- Operations

    def __set_background_image__component_operation

      o = _normalize_image_related_component
      yield :is_available, o.is_available
      yield :unavailability_reason_tuple_proc, o.reason_proc

      -> & pp do

        _sess = _begin_session
        _sess.set_background_image__( & pp[ self ] )
      end
    end

    def __OSA_script__component_operation

      o = _normalize_image_related_component
      yield :is_available, o.is_available
      yield :unavailability_reason_tuple_proc, o.reason_proc

      -> & pp do
        _sess = _begin_session
        _sess.build_osa_script_( & pp[ self ] )
      end
    end

    def __imagemagick_command__component_operation

      o = _normalize_image_related_component
      yield :is_available, o.is_available
      yield :unavailability_reason_tuple_proc, o.reason_proc

      -> & pp do
        _sess = _begin_session
        _sess.build_imagemagick_command_( & pp[ self ] )
      end
    end

    def _begin_session

      Here_::Session___.begin_cold_session__ self
    end

    def _normalize_image_related_component

      _rw = @_svc.reader_writer__

      Home_::Image_Output_Adapter::Normalize_Components.call(
        _rw, :is_required_to_make_image_ )
    end

    # -- Components

    def __background_font__component_association

      yield :required_to_make_image

      yield :internal_name, :font

      Home_::Models_::Font
    end

    def __label__component_association

      yield :required_to_make_image

      yield :generate_description

      Home_.lib_.basic::String.component_model_for :NONBLANK
    end

    # --

    def component_association_reader  # [ac] hook-in - opt-in to using this one

      Home_::Image_Output_Adapter::Common_Component_Association.
        reader_of_component_associations_by_method_in self
    end

    def kernel_
      @_svc.kernel_
    end

    Here_ = self
  end
end
