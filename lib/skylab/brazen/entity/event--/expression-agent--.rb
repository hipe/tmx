module Skylab::Brazen

  module Entity

    class Event__

      EXPRESSION_AGENT__ = ( class Expression_Agent__ < ::BasicObject

        # used for 'description' of events (typically for development & tests)

        alias_method :calculate, :instance_exec

        def method_missing i, * args
          if 1 == args.length
            _desc = args.first.inspect
          else
            _desc = args.inspect
          end
          "(#{ i } #{ _desc })"
        end

        self
      end ).new
    end
  end
end
