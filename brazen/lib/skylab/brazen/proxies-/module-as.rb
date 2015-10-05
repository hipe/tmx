module Skylab::Brazen

  module Proxies_::Module_As  # :[#085].

    class Unbound_Model

      def initialize mod

        @mod = mod
        @nf = Callback_::Name.via_module mod
      end

      def is_branch
        true  # all unadorned modules are
      end

      def name_function
        @nf
      end

      def new kr, & oes_p

        As_Bound_Model___.new self, kr, & oes_p
      end

      def const_defined? * a
        @mod.const_defined?( * a )
      end

      def __mod
        @mod
      end
    end

    class As_Bound_Model___

      # :+[#br-098] things that should probably subclass interface node base

      def initialize cls_pxy, kr, & oes_p

        @cls_pxy = cls_pxy
        @kernel = kr
        @on_event_selectively = oes_p
      end

      def fast_lookup
        NIL_
      end

      def to_unbound_action_stream
        to_lower_unbound_action_stream
      end

      def to_lower_unbound_action_stream

        _acr = Home_::Model::Child_Node_Index.new(
          @cls_pxy,
          @cls_pxy.__mod.const_get( ACTIONS_CONST_, false ) )

        _acr.to_lower_action_class_stream_
      end

      def name
        @cls_pxy.name_function
      end

      def to_kernel
        @kernel
      end

      def after_name_symbol
        NIL_
      end

      def has_description
        false
      end

      def is_branch
        true  # modules are always treated as branch nodes
      end

      def is_visible
        true
      end
    end
  end
end
