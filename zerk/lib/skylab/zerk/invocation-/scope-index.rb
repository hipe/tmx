module Skylab::Zerk

  module Invocation_

    class Scope_Index

      # any formal operations's appropriations must by definition draw
      # from within its scope stack. (this where "scope stack" gets its
      # name.) this principle recurses such that for any invocation, for
      # any operation-dependencies that will occur (recursively); all
      # nodes that will ever be depended upon exist in this first scope
      # stack. as such the subject facilitates its reuse from o.d to o.d
      # during one invocation (as described in [#027]).

      # we also carry (but do nothing with) a cache for the evaluations.

      def initialize fo
        @evaluations_cache_ = {}  # watch this
        @formal_operation = fo
      end

      def execute

        all_NTs = []
        findex_via_ntindex = []
        mode_frames = []
        ntindex_via_name_symbol = {}

        st = __build_bottom_to_top_modality_frame_stream
        frame_index = -1

        begin
          mode_frame = st.gets
          mode_frame or break
          mode_frames.push mode_frame
          frame_index += 1

          st_ = mode_frame.to_every_node_ticket_stream_
          begin
            nt = st_.gets
            nt or break

            ntindex_via_name_symbol[ nt.name_symbol ] = all_NTs.length
            all_NTs.push nt
            findex_via_ntindex.push frame_index
            redo
          end while nil

          redo
        end while nil

        @_all_NTs = all_NTs
        @_findex_via_ntindex = findex_via_ntindex
        @_modality_frames = mode_frames
        @_ntindex_via_name_symbol = ntindex_via_name_symbol
        self
      end

      def __build_bottom_to_top_modality_frame_stream

        # skip the topmost frame, which is a name function or similar. we go
        # bottom to top in case we decided we wwant to allow clobber ..

        ss = @formal_operation.selection_stack
        Common_::Stream.via_times( ss.length - 1 ) do |d|
          ss.fetch d
        end
      end

      # --

      def node_ticket_via_node_name_symbol_ k

        @_all_NTs.fetch @_ntindex_via_name_symbol.fetch k
      end

      def modality_frame_via_node_name_symbol_ k

        @_modality_frames.fetch @_findex_via_ntindex.fetch @_ntindex_via_name_symbol.fetch k
      end

      def yes_no_read_only_hash__
        @_ntindex_via_name_symbol
      end

      attr_reader(
        :evaluations_cache_,
      )
    end
  end
end
# #history: broke out of "procure bound call"
