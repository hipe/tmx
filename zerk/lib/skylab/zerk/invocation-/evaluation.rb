module Skylab::Zerk

  module Invocation_

    class Evaluation

      class << self

        def proc_for_ pbc, oi

          fetch_set = oi.fetcher_proc_for_set_symbol_via_name_symbol_

          proc_h = {

            _appropriated_: -> par do
              new( par, pbc, oi ).execute
            end,

            _bespoke_: -> par do
              # to evaluate bespokes is a concern of the pbc, not the index
              pbc.evaluate_bespoke_parameter__ par
            end,
          }

          -> par do
            ( proc_h.fetch fetch_set.call par.name_symbol )[ par ]
          end
        end

        private :new
      end  # >>

      def initialize par, pbc, oi

        @_oi = oi
        @_par = par
        @_pbc = pbc

        @_k = par.name_symbol
        @_si = oi.scope_index_

        @_cache = @_si.evaluations_cache_
      end

      def execute

        sta = @_cache[ @_k ]
        if sta
          sta.in_progress and self._CYCLIC
        else
          ___establish_state
          sta = @_cache.fetch @_k
        end

        sta.cached_evaluation_
      end

      def ___establish_state

        bs = Here_::Build_State___.new @_par, @_oi, @_pbc

        @_cache[ @_k ] = bs  # do this before next line so we can detect cycles

        @_cache[ @_k ] = bs.execute

        NIL_
      end
    end
  end
end

# #history: broke out of "operation index"
