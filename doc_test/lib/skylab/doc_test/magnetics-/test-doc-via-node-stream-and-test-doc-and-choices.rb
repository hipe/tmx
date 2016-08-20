module Skylab::DocTest

  class Magnetics_::TestDoc_via_NodeStream_and_TestDoc_and_Choices

    # exactly [#017]:the-forwards-synchronization-algorithm

    # NOTE - at present this mutates the original document! this can be
    # changed if needed; it will require a deep dupe implementation.
    # (this is to say, it mutates the document object in memory - it does
    # *not* write anything to the filesystem.)

    # note - we take as argument a node stream and not an asset document
    # by the design consideration that we want to preserve streamed-ness
    # where we can; and in this case case we can for the would-be input
    # document because the algorithm happens to process the upstream as
    # a stream and not document. (but note that because our algorithm wants
    # for the referenced (test) document to be a structured document and
    # not stream, that's what we do there.)

    # ==

    class Session

      class << self
        alias_method :begin, :new
        undef_method :new
      end  # >>

      attr_writer(
        :asset_line_stream,
        :choices,
        :original_test_line_stream,
      )

      def finish
        self
      end

      def to_string
        to_test_document.to_line_stream.reduce_into_by "" do |m, s|
          m << s
        end
      end

      def to_test_document

        in_st = remove_instance_variable :@asset_line_stream
        orig_st = remove_instance_variable :@original_test_line_stream

        # -- run through the magnetics & related (wants [#ta-005])

        o = Magnetics_
        _bs = o::BlockStream_via_LineStream_and_Single_Line_Comment_Hack[ in_st ]
        node_st = o::NodeStream_via_BlockStream_and_Choices[ _bs, @choices ]

        test_doc = @choices.test_document_parser.parse_line_stream orig_st
        orig_st.respond_to? :close and orig_st.close

        # --

        o = Here_.begin
        o.choices = @choices
        o.node_stream = node_st
        o.test_document = test_doc
        doc = o.finish
        in_st.respond_to? :close and in_st.close
        doc
      end
    end

    # ==

    class << self
      alias_method :begin, :new
      undef_method :new
    end  # >>

    def initialize
      NOTHING_  # (hi.)
    end

    attr_writer(
      :choices,
      :node_stream,
      :test_document,
    )

    def finish

      __index

      tick = -> do
        @_is_first_example_in_source = true
        tick = -> do
          @_is_first_example_in_source = false
          tick = nil
        end
      end

      st = remove_instance_variable :@node_stream
      begin
        node = st.gets
        node or break
        tick && tick[]
        @_this_example = node.to_particular_paraphernalia
        __step
        redo
      end while nil

      remove_instance_variable :@test_document
    end

    def __step

      s = @_this_example.identifying_string
      s || ::Kernel._COVER_ME  # in theory possible..

      qualified_branch = @_box[ s ]
      if qualified_branch
        @_qualified_branch = qualified_branch
        __when_node_already_exists
      else
        @_qualified_branch = nil
        __when_node_doesnt_already_exist
      end
      NIL_
    end

    def __when_node_already_exists  # #coverpoint3-2

      @_last_inserted_example = @_this_example
      @_last_receiving_branch = @_qualified_branch.parent_branch

      @_qualified_branch.example_node.replace_lines @_this_example.to_line_stream

      NIL_
    end

    def __when_node_doesnt_already_exist

      if @_is_first_example_in_source
        __prepend_this_node_to_the_beginning_of_the_document
      else
        __place_this_node_immediately_after_last_inserted_node
      end
      NIL_
    end

    def __prepend_this_node_to_the_beginning_of_the_document

      if @_box.length.zero?
        __insert_this_node_into_an_emptyesque_document
      else
        __prepend_this_node_before_the_first_node_in_the_document
      end
      NIL_
    end

    def __insert_this_node_into_an_emptyesque_document

      eg = remove_instance_variable :@_this_example
      o = @test_document.begin_insert_into_empty_document_given @choices
      o.example_node = eg
      o = o.finish
      @_last_inserted_example = eg
      @_last_receiving_branch = o.last_receiving_branch
      NIL_
    end

    def __prepend_this_node_before_the_first_node_in_the_document  # #coverpoint3-1

      _qualif = @_box.h_.fetch @_box.first_name

      eg = remove_instance_variable :@_this_example
      branch = _qualif.parent_branch
      @_last_inserted_example = eg
      @_last_receiving_branch = branch
      branch.prepend_example eg
      NIL_
    end

    def __place_this_node_immediately_after_last_inserted_node  # #coverpoint3-3

      eg = remove_instance_variable :@_this_example
      after_this = remove_instance_variable :@_last_inserted_example
      @_last_inserted_example = eg
      @_last_receiving_branch.insert_example_after after_this, eg
      NIL_
    end

    def __index

      # here's the main thing(s):
      #
      #   • indirectly the below asserts uniqueness of the identifying string
      #     (description string) of each example within the context of one
      #     document - this will bork loudly for test files of a certain
      #     structure.
      #
      #   • because we never delete or move (per se) nodes, it's safe to
      #     associate each existing node with its parent branch (right?)

      bx = Common_::Box.new
      st = @test_document.to_qualified_example_node_stream
      begin
        o = st.gets
        o or break
        bx.add o.example_node.identifying_string, o
        redo
      end while nil

      @_box = bx
      NIL_
    end

    Here_ = self
  end
end
