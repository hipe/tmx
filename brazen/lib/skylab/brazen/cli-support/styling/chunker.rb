module Skylab::Brazen

  module CLI_Support

    module Styling

      module Chunker

        class << self

          def via_sexp sexp

            st = Implementor___.new sexp
            Callback_.stream do
              st._gets
            end
          end
        end  # >>

        Implementor___ = Callback_::Session::Ivars_with_Procs_as_Methods.new :_gets

        # <- 2

    -> do

      state_h = {
        initial: {
          string: -> _ do
            [ [ :move, :string ], [ :start ], [ :accept ] ]
          end,
          style: -> _ do
            [ [ :move, :style ], [ :start ], [ :accept ] ]
          end
        },
        string: {
          style: -> x do
            if 0 == x[1]
              [ [ :accept ] ]
            else
              [ [ :cut ], [ :move, :style ], [ :start ],  [ :accept ] ]
            end
          end
        },
        style: {
          string: -> _ do
            [ [ :accept ] ]
          end,
          style: -> x do
            if 0 == x[1]
              [ [ :accept ], [ :cut ], [ :move, :initial ] ]
            else
              [ [ :accept ] ]
            end
          end
        }
      }

      Implementor___.send :define_method, :initialize do | sexp |

        state = :initial
        hot = true

        st = Callback_::Polymorphic_Stream.via_array sexp

        building = nil

        fetch = -> x do
          curr = state_h.fetch state do |sta|
            raise ::KeyError, "nothing known about current state :#{ sta }"
          end
          func = curr.fetch x[0] do |sta|
            raise ::KeyError, "no transition from :#{ state } to :#{ sta }"
          end
          func[ x ]
        end

        op_h = nil

        run = -> op_a do
          op_a.each do |op, *args|
            op_h.fetch( op )[ *args ]
          end
        end

        x = stay = res = nil

        op_h = {
          move: -> sta do
            state = sta
          end,
          start: -> do
            building and fail 'sanity'
            building = []
          end,
          accept: -> do
            building << x
          end,
          cut: -> do
            stay = false
            res = building
            building = nil
          end
        }

        @_gets = -> do
          res = nil
          while hot

            if st.no_unparsed_exists
              building and op_h.fetch(:cut)[]
              break( hot = nil )
            end

            x = st.gets_one
            op_a = fetch[ x ]
            stay = true
            run[ op_a ]
            stay or break
          end
          res
        end
      end
    end.call
    # -> 2
      end
    end
  end
end
