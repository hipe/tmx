module Skylab::Brazen

  module Entity

    module Concerns_::Ad_Hoc

      class Processors

        def initialize sess

          @_p = -> do

            mod = sess.client
            if mod.const_defined? CONST__
              h = mod.const_get CONST__
            end

            if h
              @_p = -> do

                p = h[ sess.upstream.current_token ]
                if p
                  sess.upstream.advance_one
                  p[ sess ]
                else
                  KEEP_PARSING_
                end
              end
              @_p[]
            else
              # if we don't do this, we can add a first ad-hoc later, at
              # a cost of more expensive parsing
              @_p = -> do
                KEEP_PARSING_
              end
              KEEP_PARSING_
            end
          end
        end

        def consume_passively
          @_p[]
        end
      end

      class Processor_Processor

        def initialize sess

          @_sess = sess

          @_p = -> k, p do

            mod = @_sess.client
            if mod.const_defined? CONST__
              h = mod.const_get CONST__
              if ! mod.const_defined? CONST__, false
                h = h.dup
                mod.const_set CONST__, h
              end
            else
              h = {}
              mod.const_set CONST__, h
            end

            @_p = -> k_, p_ do

              had = h.fetch k_ do
                h[ k_ ] = p_
                NIL_
              end
              had and self._DESIGN_ME
              KEEP_PARSING_
            end
            @_p[ k, p ]
          end
        end

        def consume

          st = @_sess.upstream
          @_p[ st.gets_one, st.gets_one ]
        end
      end

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

      CONST__ = :ENTITY_AD_HOC_PROCESSORS___

    end
  end
end
