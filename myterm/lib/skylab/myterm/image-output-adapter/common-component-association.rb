module Skylab::MyTerm

  module Image_Output_Adapter

    class Common_Component_Association < ACS_::Component_Association

      # here's how you implement custom meta-components #[#ac-013]:
      #
      # model meta-components beyond what "ships" with the [ac] component
      # association; that pertain to producing images..

      def accept__internal_name__meta_component x
        @__internal_name_symbol = x
        NIL_
      end

      def get_internal_name_string__

        sym = __internal_name_symbol
        if sym
          sym.id2name
        else
          # @name.as_slug.gsub DASH_, EMPTY_S_  # for example
          @name.as_slug
        end
      end

      attr_reader :__internal_name_symbol

      # --

      def accept__required_to_make_image__meta_component
        @is_required_to_make_image_ = true
        NIL_
      end

      attr_reader :is_required_to_make_image_
    end
  end
end
