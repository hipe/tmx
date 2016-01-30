module Skylab::MyTerm

  class Image_Output_Adapters_::Imagemagick  # (notes in [#003], [#004])

    def initialize svc, & pp
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
