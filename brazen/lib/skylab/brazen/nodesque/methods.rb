module Skylab::Brazen

  module Nodesque::Methods

    module Unbound_Methods

      def adapter_class_for _
        NIL_
      end

      def after_name_symbol
        NIL_
      end

      def fast_lookup
        NIL_
      end

      def is_promoted
        false
      end

      def node_identifier
        @__node_ID ||= Home_::Nodesque::Identifier.via_name_function name_function, self
      end

      def preconditions
        NIL_
      end

      def silo_module
        NIL_
      end
    end

    module Bound_Methods

      def description_proc_for_summary_of_under _, _
        description_proc
      end

      def description_proc
        NIL_
      end

      def after_name_symbol
        NIL_
      end

      def fast_lookup
        NIL_
      end

      def is_visible
        true
      end

      def kernel
        @kernel  # dodgy
      end
    end

    # below gives us less orphans at cost of breaking the clean taxonomy

    module Branchesque_Defaults

      Unbound_Methods = Unbound_Methods.dup

      module Unbound_Methods

        def is_branch
          true
        end
      end

      Bound_Methods = Bound_Methods.dup

      module Bound_Methods

        def is_branch
          true
        end
      end
    end

    module Actionesque_Defaults

      Unbound_Methods = Unbound_Methods.dup

      module Unbound_Methods

        def custom_action_inflection
          NIL_
        end

        def is_branch
          false
        end

        def name_function_class  # #hook-in
          Home_::Actionesque::Name
        end
      end

      Bound_Methods = Bound_Methods.dup

      module Bound_Methods
        def is_branch
          false
        end
      end
    end
  end
end
