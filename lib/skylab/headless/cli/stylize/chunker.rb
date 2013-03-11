module Skylab::Headless

  class CLI::Stylize::Chunker  # assumes immutable sexp

    def gets
      @gets[]
    end

  protected

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

      define_method :initialize do |sexp|
        state = :initial
        hot = true
        scn = Headless::Services::Array::Scanner.new sexp
        building = nil

        fetch = -> x do
          curr = state_h.fetch state do |st|
            raise ::KeyError, "nothing known about current state :#{ st }"
          end
          func = curr.fetch x[0] do |st|
            raise ::KeyError, "no transition from :#{ state } to :#{ st }"
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
          move: -> st do
            state = st
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

        @gets = -> do
          res = nil
          while hot
            if scn.eos?
              building and op_h.fetch(:cut)[]
              break( hot = nil )
            end
            x = scn.gets
            op_a = fetch[ x ]
            stay = true
            run[ op_a ]
            stay or break
          end
          res
        end
      end
    end.call
  end

  class Headless::CLI::Stylize::Chunker::Enumerator < ::Enumerator

  protected

    def initialize sexp
      super(& -> y do
        scn = CLI::Stylize::Chunker.new sexp
        while x = scn.gets
          y << x
        end
        nil
      end)
    end
  end
end
