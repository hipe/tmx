module Skylab::Fields

  module Entity

    module AdHocProcessor_

      class Processors

        def initialize sess

          @_p = -> do

            mod = sess.client
            if mod.const_defined? CONST__
              h = mod.const_get CONST__
            end

            if h
              @_p = -> do

                p = h[ sess.upstream.head_as_is ]
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

      class ProcessorProcessor

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

          scn = @_sess.upstream
          @_p[ scn.gets_one, scn.gets_one ]
        end
      end

      class MutableNonterminalQueue

        def initialize
          @box = Common_::Box.new
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
          if @h.key? parse_context.upstream.head_as_is
            parse_p = @h.fetch parse_context.upstream.head_as_is
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
