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

        ft = mod.entry_tree
        ft || fail
        @__file_tree = ft
        @__module = mod
        @_stream = :__stream_first_time
        self
      end

      def __stream_first_time

        cache = []
        mod = @__module
        st = @__file_tree.to_asset_ticket_stream

        Common_.stream do  # hand-written map-reduce for clarity

          begin
            sm = st.gets

            if ! sm  # once we reach the end, don't repeat this work.
              remove_instance_variable :@__file_tree
              remove_instance_variable :@__module
              @__module_cache = cache
              @_stream = :__stream_subsequent_time
              break
            end

            head = sm.entry_group_head
            if WHITE_RX___ !~ head  # the "reduce"
              redo
            end

            _const = Home_::Sexp::Const_via_Tokens_.via_head head
            x = mod.const_get _const, false
            cache.push x
            break
          end while above
          x
        end
      end

      WHITE_RX___ = /\Awhen-/

      def __stream_subsequent_time
        Common_::Stream.via_nonsparse_array @__module_cache
      end

      def expression_session_via_sexp_stream__ st

        best_match = nil
        idea = Here_::Idea_.new_via_sexp_stream__ st

        st = send @_stream
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
