module Skylab::MyTerm

  class Image_Output_Adapters_::Imagemagick  # (notes in [#003], [#004])

    def initialize svc
      @_svc = svc
    end

    # -- Operations

    def __imagemagick_command__component_operation

      _rw = @_svc.reader_writer__

      o = Home_::Image_Output_Adapter::Normalize_Components.call(
        _rw, :is_required_to_make_image_ )

      yield :is_available, o.is_available

      yield :unavailability_reason_tuple_proc, o.reason_proc

      -> do
        self._K
      end
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
  end
end
# #pending-rename: b.d
