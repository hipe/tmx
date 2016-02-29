module Skylab::Human

  module Sexp

    class Expression_Collection

      class << self

        def new_via_multipurpose_module__ mod
          new.__init_etc mod
        end

        private :new
      end  # >>

      def __init_etc mod

        # assume that `mod` has a mix of nodes under it, some that are
        # "magnetic" and others that are not. assume the node is magetic
        # IFF it's name matches the pattern we untilize below. map-reduce
        # the stream down to only those that are magnetic.
        #
        # assume that the stream produced by this streamer is guaranteed to
        # be exhausted (i.e always reach the end). cache the reduction it
        # does so we do not repeat this work every time we have a lookup.

        et = mod.entry_tree  # fail early

        @_streamer = -> do

          st = et.to_stream
          cache = []

          Callback_.stream do  # hand-written map-reduce for clarity

            begin
              en = st.gets

              if ! en  # once we reach the end, don't repeat this work.
                @_streamer = -> do
                  Callback_::Stream.via_nonsparse_array cache
                end
                break
              end

              if WHITE_RX___ !~ en.corename  # the "reduce"
                redo
              end

              x = mod.const_get en.name.as_const, false
              cache.push x
              break
            end while nil
            x
          end
        end

        self
      end

      WHITE_RX___ = /\Awhen-/

      def expression_session_via_sexp_stream__ st

        best_match = nil
        idea = Here_::Idea_.new_via_sexp_stream__ st

        st = @_streamer[]
        begin
          x = st.gets
          x or break
          match = x.match_for_idea__ idea
          if match
            if best_match
              if best_match <= match
                best_match = match
              end
            else
              best_match = match
            end
          end
          redo
        end while nil

        if best_match
          best_match.to_expression_session__
        else
          self._LOGIC_HOLE
        end
      end
    end
  end
end
