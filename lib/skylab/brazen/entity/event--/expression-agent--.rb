module Skylab::Brazen

  module Entity

    class Event__

      EXPRESSION_AGENT__ = ( class Expression_Agent__ < ::BasicObject

        # used for 'description' of events (typically for development)

        alias_method :calculate, :instance_exec

        def method_missing i, * args
          "(#{ i } #{ args.map( & :inspect ) })"
        end

        self
      end ).new
    end
  end
end
