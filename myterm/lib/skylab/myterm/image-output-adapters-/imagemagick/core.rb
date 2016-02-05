module Skylab::MyTerm

  class Image_Output_Adapters_::Imagemagick  # (notes in [#003], [#004])

    def initialize svc

      @_svc = svc
      @_unavailability = method :__image_gen_related_component_unavailability
      @_use_cached_unavailability = false
    end

    # -- Operations

    def __set_background_image__component_operation

      yield :unavailability, @_unavailability

      -> & pp do

        _sess = _begin_session
        _sess.set_background_image__( & pp[ self ] )
      end
    end

    def __OSA_script__component_operation

      yield :unavailability, @_unavailability

      -> & pp do
        _sess = _begin_session
        _sess.build_osa_script_( & pp[ self ] )
      end
    end

    def __imagemagick_command__component_operation

      yield :unavailability, @_unavailability

      -> & pp do
        _sess = _begin_session
        _sess.build_imagemagick_command_( & pp[ self ] )
      end
    end

    def _begin_session

      Here_::Session___.begin_cold_session__ self
    end

    def __image_gen_related_component_unavailability _fo

      if @_use_cached_unavailability
        @_cached_unavailability
      else
        @_use_cached_unavailability = true   # #during [#014] maybe use [ze] index instead
        x = ___determine_image_generational_unavailability
        @_cached_unavailability = x
        x
      end
    end

    def ___determine_image_generational_unavailability

      _rw = @_svc.reader_writer__

      _o = Home_::Image_Output_Adapter::Normalize_Components.call(
        _rw, :is_required_to_make_image_ )

      _o.to_unavailability
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
