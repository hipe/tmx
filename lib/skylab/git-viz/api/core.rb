module Skylab::GitViz

  module API

    def self.invoke _API_action_locator_x, * x_a
      x_a.unshift LOC_X_, _API_action_locator_x
      Session__.new.invoke_with_iambic x_a
    end

    LOC_X_ = :API_action_locator_x

    def self.invoke_with_iambic x_a
      Session__.new.invoke_with_iambic x_a
    end

    class Session__

      def invoke_with_iambic x_a
        _unbound = Resolve_Some_Unbound__.new( x_a ).execute
        _unbound[ :session, self, * x_a ]
      end
    end

    class Resolve_Some_Unbound__
      def initialize x_a
        @x_a = x_a
      end
      def execute
        API::Actions__.const_fetch resolve_some_locator_x
      end
      private
      def resolve_some_locator_x
        while LOC_X_ == @x_a.first
          @x_a.shift ; locator_x = @x_a.shift
        end  # [#004]: #in-API-invocation-the-order-matters
        locator_x or raise ::ArgumentError, say_no_locator_x
      end
    private
      def say_no_locator_x
        "we don't know what unbound action to resolve without '#{ LOC_X_ }'"
      end
    end

    MetaHell = GitViz::Lib_::MetaHell[]

    MetaHell::MAARS[ self ]

    module Actions__
      MetaHell::Boxxy[ self ]
    end
  end
end
