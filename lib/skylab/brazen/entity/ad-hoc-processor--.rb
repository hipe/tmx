module Skylab::Brazen

  module Entity

    module Ad_Hoc_Processor__

      class Mutable_Nonterminal_Queue

        def initialize
          @box = Callback_::Box.new
          h = nil
          @box.instance_exec do
            h = @h
          end
          @h = h
        end

        def add_processor name_i, proc_i
          @box.add name_i, proc_i
          nil
        end

        def receive_parse_context parse_context
          if @h.key? parse_context.upstream.current_token
            parse_p = @h.fetch parse_context.upstream.current_token
            parse_p[ parse_context ]
          else
            KEEP_PARSING_
          end
        end
      end
    end
  end
end
