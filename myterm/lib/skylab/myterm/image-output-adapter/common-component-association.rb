module Skylab::MyTerm

  module Image_Output_Adapter

    class Common_Component_Association < Arc_::ComponentAssociation

      # here's how you implement custom meta-components #[#ac-013]:
      #
      # model meta-components beyond what "ships" with the [ac] component
      # association; that pertain to producing images..


      def initialize name_sym

        @is_used_to_make_image__ = true
        super name_sym
      end

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

      def accept__is_used_to_make_image__meta_component b
        @is_used_to_make_image__ = b ; nil
      end

      attr_reader :is_used_to_make_image__
    end
  end
end
