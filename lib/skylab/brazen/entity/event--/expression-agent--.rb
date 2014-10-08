module Skylab::Brazen

  module Entity

    class Event__

      EXPRESSION_AGENT__ = ( class Expression_Agent__ < ::Object

        # used for 'description' of events (typically for development & tests)

        alias_method :calculate, :instance_exec

        def method i
          p = build_stringer_proc_for_method_name i
          -> * args do
            p[ args ]
          end
        end

        def method_missing i, * args
          build_stringer_proc_for_method_name( i ).call args
        end

        def build_stringer_proc_for_method_name meth_i
          -> a do
            _args = case 1 <=> a.length
            when  1 ;
            when  0 ; " #{ dsc_x a.first }"
            when -1 ; dsc_list a
            end
            "(#{ meth_i }#{ _args })"
          end
        end

        def dsc_list a
          _s_a = a.map do |x|
            dsc_x x
          end
          " [#{ _s_a * ', ' }]"
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
