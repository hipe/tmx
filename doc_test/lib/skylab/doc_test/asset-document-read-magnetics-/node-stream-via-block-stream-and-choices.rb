module Skylab::DocTest

  class Magnetics_::NodeStream_via_BlockStream_and_Choices

    # see [#024] node theory

    extend Common_::Actor::ProcLike

    def initialize bs, tfcp, cx
      @block_stream = bs
      @choices = cx
      @__test_file_context_proc = tfcp
    end

    def execute

      @_state = :__first_node

      Common_.stream do
        send @_state
      end
    end

    def __first_node

      # this is not lossless. this is lossful: we want only comment blocks

      _bs = remove_instance_variable :@block_stream
      @_comment_block_stream = _bs.reduce_by do |blk|
        :comment == blk.category_symbol
      end

      @_state = :_main
      send @_state
    end

    def _main

      begin

        cb = @_comment_block_stream.gets

        if ! cb
          x = cb
          @_state = :_NOTHING
          break
        end

        __thoroughly_index_comment_block cb

        if @_disreagard_this_comment_block
          redo
        end

        if @_seen_other
          x = __assemble_whole_node_because_OE
        else
          __transition_to_flat_state
          x = send @_state
        end
        break
      end while nil
      x
    end

    def __assemble_whole_node_because_OE  # #coverpoint2-3

      Models_::Context.via_valid_pair_array_and_choices__(

        remove_instance_variable( :@_pairs ),
        @__test_file_context_proc,
        @choices,
      )
    end

    def __transition_to_flat_state

      _cleanup_ivars

      @_cache_stream = Common_::Stream.via_nonsparse_array(
        remove_instance_variable :@_pairs )

      @_state = :___gets_from_cache_flatly ; nil
    end

    def _cleanup_ivars
      remove_instance_variable :@_disreagard_this_comment_block
      remove_instance_variable :@_seen_other ; nil
    end

    def ___gets_from_cache_flatly

      pair = @_cache_stream.gets
      if pair  # like #spot-4

        code_run = pair.code_run
        _discu_run = pair.discussion_run
        code_run.has_magic_copula or Home_._SANITY  # because then not flat

        Models_::ExampleNode.via_runs_and_choices_ _discu_run, code_run, @choices

      else
        remove_instance_variable :@_cache_stream
        @_state = :_main
        send @_state
      end
    end

    def __thoroughly_index_comment_block cb

      st = Magnetics_::RunStream_via_CommentBlock[ cb ]
      pairs = nil

      run = st.gets
      begin

        :discussion == run.category_symbol or Home_._SANITY

        run_ = st.gets
        if ! run_
          break
        end
        :code == run_.category_symbol or Home_._SANITY

        if run_.has_magic_copula
          seen_example = true
        else
          seen_other = true
        end
        ( pairs ||= [] ).push DiscussionRunAndCodeRun___[ run, run_ ]

        run = st.gets
      end while run

      if pairs
        if ! seen_example
          disreagard_this_comment_block = true  # #coverpoint2-2 ("OO")
        end
      else
        disreagard_this_comment_block = true  # #coverpoint2-1 (empty set)
      end

      @_disreagard_this_comment_block = disreagard_this_comment_block
      @_pairs = nil
      @_seen_other = nil

      if disreagard_this_comment_block
        remove_instance_variable :@_pairs
        remove_instance_variable :@_seen_other
      else
        @_pairs = pairs
        @_seen_other = seen_other
      end
      NIL_
    end

    # ==

    DiscussionRunAndCodeRun___ = ::Struct.new :discussion_run, :code_run
  end
end
