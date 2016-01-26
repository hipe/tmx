module Skylab::Callback

  # ->

    class Event

      Models_ = ::Module.new

      class Models_::Expression_Agent  # :[#010].

        # used for 'description' of events (typically for development & tests)

        alias_method :calculate, :instance_exec

        def modality_const
          NIL_
        end

        def new_expression_context  # :+#experiment
          ::String.new
        end

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

          if x
            if x.respond_to? :description
              x.description

            elsif x.respond_to? :id2name
              x.inspect

            elsif x.respond_to? :each_with_index
              x.inspect

            elsif x.respond_to? :ascii_only?
              x.inspect

            else
              # Home_.lib_.basic::String.via_mixed x
              x.to_s
            end
          else
            x.inspect
          end
        end

        INSTANCE = new.freeze
      end
    end

    # <-
end
# #pending-rename - this is not a model (but meh)
