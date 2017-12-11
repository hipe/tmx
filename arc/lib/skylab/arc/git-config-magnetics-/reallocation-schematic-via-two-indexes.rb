module Skylab::Arc

  class GitConfigMagnetics_::ReallocationSchematic_via_TwoIndexes < Common_::MagneticBySimpleModel

    # touch on/implement exactly:
    #   - [#024.K] why we do the crazy diff thing
    #   - [#024.L] the crazy diff thing, at the center of it all AND
    #   - [#024.M] the beginning of the final clusterization [#here.M]

    # to summarize, having indexed both the components and the existing
    # document, *and* knowing all the associations we will make between the
    # components and the document (i.e how they "line up" "destructively);
    #
    # we now assemble a new schematic with instructions on where each
    # section is coming from: for each section in the new document,
    #
    #   - either it is re-used as-is in the existing document (but possibly moved)
    #   - OR it is brand new (NOT COVERED)
    #   - OR it is an existing section retro-fitted (NOT IMPLEMENTED)

    # -
      attr_writer(
        :existing_document_index,
        :pluralton_components_index,
      )

      def execute

        @_do_trace = false
        # @__trace = -> s { $stderr.puts s }  # e.g

        @_index_for_item_via_association_offset = {}
        __process_lines_of_diff
        __simplify_the_diff_to_two_hashes
        __do_this_next_thing
      end

      def __do_this_next_thing

        # experimentally we munge both sections that have no association with
        # the components and sections that associate with components that
        # moved (per the diff). the documentation obliquely makes a case for this.

        wee = []
        yes_h = remove_instance_variable :@__yes_hash
        no_h = remove_instance_variable :@__no_hash

        @pluralton_components_index.associated_locator_offsets_schematic.each do |cluster|
          count = 0
          a = []

          maybe_flush_count = -> do
            if count.nonzero?
              a.push [ :_non_associated_, count ].freeze
              count = 0
            end
          end

          cluster.each do |d|
            if d
              if yes_h[ d ]
                maybe_flush_count[]
                a.push [ :_associated_, d ]
              else
                no_h.fetch d  # sanity
                count += 1
              end
            else
              count += 1
            end
          end

          maybe_flush_count[]
          wee.push a.freeze
        end

        wee.freeze
      end

      def __simplify_the_diff_to_two_hashes
        yes_h = {} ; no_h = {}
        _h = remove_instance_variable :@_index_for_item_via_association_offset
        _h.each_pair do |d, idx|
          if idx.finish
            yes_h[ d ] = true
          else
            no_h[ d ] = true
          end
        end
        @__yes_hash = yes_h ; @__no_hash = no_h ; nil
      end

      # -- E: process runs

      THESE___ = {
        add: :__process_add_run,
        context: :__process_context_run,
        remove: :__process_remove_run,
      }

      # ~ context run

      def __process_context_run context_run
        _process_run :__process_context_line, context_run
        NIL
      end

      def __process_context_line d

        @_do_trace and _trace " #{ d }"

        _touch_item_index( d ).receive_stationary

        # (a context line advanced both the "left" side and the "right":)
        @CURRENT_LINE_NUMBER_OF_GUIDE_FILE_FOR_BEFORE += 1
        @CURRENT_LINE_NUMBER_OF_GUIDE_FILE_FOR_AFTER += 1
        NIL
      end

      # ~ add run

      def __process_add_run add_run
        _process_run :__process_add_line, add_run
        NIL
      end

      def __process_add_line d

        @_do_trace and _trace "+#{ d }"

        _touch_item_index( d ).receive_add

        # (an add advances the counter on the "right" side, but not left:)
        @CURRENT_LINE_NUMBER_OF_GUIDE_FILE_FOR_AFTER += 1
        NIL
      end

      # ~ remove run

      def __process_remove_run remove_run
        _process_run :__process_remove_line, remove_run
        NIL
      end

      def __process_remove_line d

        @_do_trace and _trace "-#{ d }"

        _touch_item_index( d ).receive_remove

        # (a remove advances the counter on the "right" side, but not left:)
        @CURRENT_LINE_NUMBER_OF_GUIDE_FILE_FOR_BEFORE += 1
        NIL
      end

      # -- D: support for the above section

      def _process_run m, run
        s_st = run.TO_LINE_CONTENT_STREAM
        s = s_st.gets
        begin
          _d = INTEGER_RX___.match( s )[ 0 ].to_i
          send m, _d
          s = s_st.gets
        end while s
        NIL
      end

      INTEGER_RX___ = /\A\d+$/  # used for sanity

      def _touch_item_index d
        h = @_index_for_item_via_association_offset
        h.fetch d do
          x = IndexForItem___.new
          h[ d ] = x
          x
        end
      end

      def _trace s
        @__trace[ s ] ; nil
      end

      # -- C: process lines in diff

      def __process_lines_of_diff

        _diff = __diff
        @_hunk_stream = _diff.to_hunk_stream

        _always_same = @_hunk_stream.gets
        _always_same.category_symbol == :diff_header || oops

        # (this "hunk" (not really a hunk) is a part of the beginning of
        # every diff-for-file, it has the before file name and after file
        # name, which is entirely uninteresting to us here.)

        @CURRENT_LINE_NUMBER_OF_GUIDE_FILE_FOR_BEFORE = 1
        @CURRENT_LINE_NUMBER_OF_GUIDE_FILE_FOR_AFTER = 1

        hunk = @_hunk_stream.gets
        begin
          _run_st = hunk.to_run_stream
          __process_run_stream _run_st

          hunk = @_hunk_stream.gets
          hunk && self._COVER_ME__multiple_hunks__
          break
        end while something

        NIL
      end

      def __process_run_stream run_st

        run = run_st.gets
        run.category_symbol == :header || oops

        @CURRENT_LINE_NUMBER_OF_GUIDE_FILE_FOR_BEFORE == run.old_begin || oops
        @CURRENT_LINE_NUMBER_OF_GUIDE_FILE_FOR_AFTER == run.new_begin || oops

        run = run_st.gets
        begin
          send THESE___.fetch( run.category_symbol ), run
          run = run_st.gets
        end while run

        NIL
      end

      # -- B: produce diff

      def __diff

        a = []
        @pluralton_components_index.associated_locator_offsets_schematic.each do |sparse|
          sparse.each do |d|
            d || next
            a.push d
          end
        end

        _put_these_in_file_CURRENT = a
        _put_these_in_file_GOAL = @pluralton_components_index.associated_locators.length.times.to_a

        _current_st = Stream_.call _put_these_in_file_CURRENT do |d|
          d.to_s
        end

        _goal_st = Stream_.call _put_these_in_file_GOAL do |d|
          d.to_s
        end

        diff = Home_.lib_.system.diff.by do |o|
          o.left_line_stream = _current_st
          o.right_line_stream = _goal_st
        end

        diff.is_the_empty_diff && sanity

        diff
      end
    # -

    # ==

    class IndexForItem___

      def initialize
        @_mutex_for_add = nil
        @_mutex_for_remove = nil
        @is_stationary = false
      end

      def receive_stationary
        remove_instance_variable :@_mutex_for_add
        remove_instance_variable :@_mutex_for_remove
        @is_stationary = true
      end

      def receive_add
        remove_instance_variable :@_mutex_for_add
        @_is_add = true
      end

      def receive_remove
        remove_instance_variable :@_mutex_for_remove
        @_is_remove = true
      end

      def finish
        if @is_stationary
          true
        else
          @_is_add && @_is_remove or fail
          false
        end
      end

      attr_reader(
        :is_stationary,
      )
    end

    # ==
    # ==
  end
end
# #born (was stashed for ~6 months)
