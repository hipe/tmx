module Skylab::Brazen

  module Entity

    class Event__

      EXPRESSION_AGENT__ = ( class Expression_Agent__ < ::Object

        # used for 'description' of events (typically for development & tests)

        alias_method :calculate, :instance_exec

        def method_missing i, * args
          if 1 == args.length
            _desc = dsc_x args.first
          else
            _desc = "[#{ args.map( & method( :dsc_x ) ) * ', ' }]"
          end
          "(#{ i } #{ _desc })"
        end

        def dsc_x x
          if x.respond_to? :description
            x.description
          else
            x.inspect
          end
        end

        self
      end ).new
    end
  end
end
