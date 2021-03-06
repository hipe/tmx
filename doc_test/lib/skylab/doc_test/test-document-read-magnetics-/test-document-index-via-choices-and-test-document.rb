module Skylab::DocTest

  class TestDocumentReadMagnetics_::TestDocumentIndex_via_Choices_and_TestDocument  # 1x

    # exactly the probably first of the probably three steps in [#035],
    # which at present is hazily defined there. our client will probably
    # need to be able to know/do, given an identifying string:
    #
    #   A) whether any node occupies that universal "slot" in the document
    #
    #   B) if existent, some shape characteristics of that node
    #      (namely, one boolean characteristic - whether it is a branch)
    #
    #   C) it probably wants the ability to replace that node
    #      (in its parent node).

    def initialize doc, cx, & l
      @choices = cx
      @listener = l
      @ersatz_test_document = doc
    end

    def execute

      desc = @choices.best_root_contextesque_node_for_test_document__ @ersatz_test_document

      @_universal_name_box = Common_::Box.new

      bi = Recurse__.into_for desc, self
      if bi
        TestDocumentIndex___.new @_universal_name_box, bi, desc, @ersatz_test_document
      else
        bi
      end
    end

    attr_reader(
      :listener,
      :_universal_name_box,
    )

    # ==

    class TestDocumentIndex___

      def initialize unb, bi, rcn, td
        @branch_index = bi
        @existing_document_node = rcn
        @test_document = td
        @__universal_name_box = unb
      end

      def lookup_via_identifying_string k
        @__universal_name_box.h_[ k ]
      end

      attr_reader(
        :branch_index,
        :existing_document_node,
        :test_document,
      )
    end

    # ==

    class Recurse__

      class << self
        def into_for bn, rsx
          new( bn, rsx ).execute
        end
        private :new
      end  # >>

      def initialize bn, rsx
        @_branch_docnode = bn
        @listener = rsx.listener
        @_universal_name_box = rsx._universal_name_box
      end

      def execute
        @_node_indexes_of_interest = []
        @_seen_a_before_all_block = false
        _ok = __index
        _ok && __finish
      end

      def __finish
        if @_seen_a_before_all_block
          _bab = @__before_all_block
        end
        BranchIndex___.new _bab, @_node_indexes_of_interest, @_branch_docnode
      end

      def __index
        ok = ACHIEVED_
        scn = @_branch_docnode.to_immediate_child_scanner
        begin
          scn.advance_one  # assume the first line is a `describe` or `context` line
          scn.no_unparsed_exists && break
          no = scn.head_as_is

          sym = no.category_symbol
          :blank_line == sym && redo

          ok = send INDEX_THIS___.fetch( sym ), no
          ok || break
          redo
        end while above
        ok
      end

      INDEX_THIS___ = {
        before: :__maybe_index_a_before_node,
        context_node: :__index_a_context_node,
        ending_line: :__ending_line_is_noop,
        example_node: :__index_an_example_node,
        nonblank_line: :__probably_dont_index_a_nonblank_line,
        shared_subject: :__index_a_shared_subject,
      }

      def __maybe_index_a_before_node no  # #todo this is too high here

        _hi = no.node_internal_identifying_symbol
        if BEFORE_ALL_ == _hi
          __index_before_all no
        else
          self._COVER_ME_before_each_do_nothing
          ACHIEVED_
        end
      end

      def __index_before_all no
        if @_seen_a_before_all_block
          self._COVER_ME_fail_softly
        else
          @_seen_a_before_all_block = true
          @__before_all_block = no
          @_node_indexes_of_interest.push Before_all_placeholder___[]
          ACHIEVED_
        end
      end

      def __index_a_context_node no

        # we exploit the universal name index for two (perhaps somewhat at
        # odds) purposes: 1) when the indexing is all done, we use it to
        # reference nodes of interest by name. 2) *during* the indexing, we
        # want to use it to detect name collisions.
        #
        # when we are recursing into a branch node, we want to be able to
        # detect name collisions even against the name of any branch we are
        # inside. but the branch index isn't complete until we return from
        # the recurse. so we use a placeholder :/

        tmp = TemporaryBranchNodeIndex___.new do |o|
          o.existing_child_document_node = no
        end

        ok = _add_to_universal_name_index tmp
        if ok
          bi = self.class.into_for no, self  # recurse
          if bi
            @_node_indexes_of_interest.push bi
            @_universal_name_box.replace tmp.document_unique_identifying_string, bi
          else
            ok = bi
          end
        end
        ok
      end

      def __index_a_shared_subject no
        @_node_indexes_of_interest.push SharedSubjectNodeIndex___.new(
          no, @_branch_docnode )
        ACHIEVED_
      end

      def __index_an_example_node no

        ni = ExistingExampleNodeIndex___.new do |o|
          o.existing_child_document_node = no
          o.existing_parent_document_node = @_branch_docnode
        end

        ok = _add_to_universal_name_index ni
        ok and @_node_indexes_of_interest.push ni
        ok
      end

      def __probably_dont_index_a_nonblank_line _
        ACHIEVED_
      end

      def __ending_line_is_noop _
        ACHIEVED_
      end

      def _add_to_universal_name_index node_index

        k = node_index.document_unique_identifying_string
        @_universal_name_box.add k, node_index
        ACHIEVED_  # reserved for if we ever soft-fail on name collisions
      end

      attr_reader(
        :listener,
        :_universal_name_box,
      )
    end

    # ==

    class BranchIndex___

      def initialize bab, cni, dn
        if bab
          @has_before_all = true
          @before_all_block = bab
        end
        @child_node_indexes = cni
        @existing_document_node = dn
      end

      def to_stream_of sym
        Stream_[ @child_node_indexes ].reduce_by do |o|
          sym == o.category_symbol
        end
      end

      attr_reader(
        :child_node_indexes,
        :existing_document_node,
        :before_all_block,
        :has_before_all,
      )

      def is_of_branch
        true
      end

      def category_symbol
        :probably_context_or_describe
      end
    end

    # ==

    NodeOfInterestIndex__ = ::Class.new

    Before_all_placeholder___ = Lazy_.call do
      BeforeAllNodeIndex___.new :BEFORE_ALL_PLACEHOLDER
    end

    class BeforeAllNodeIndex___

      def initialize x
        @HI = x
      end

      attr_reader(
        :HI,
      )

      def category_symbol
        :before_all
      end
    end

    class SharedSubjectNodeIndex___

      def initialize no, pa
        @existing_child_document_node = no
        @existing_parent_document_node = pa
      end

      attr_reader(
        :existing_child_document_node,
        :existing_parent_document_node,
      )

      def category_symbol
        :shared_subject
      end
    end

    class ExistingExampleNodeIndex___ < NodeOfInterestIndex__

      def category_symbol
        :example_node
      end

      def is_of_branch
        false
      end
    end

    class TemporaryBranchNodeIndex___ < NodeOfInterestIndex__

      def is_of_branch
        true
      end
    end

    class NodeOfInterestIndex__

      def initialize
        yield self
        freeze
      end

      def dup_by  # (in its use case this fully overwrites, but meh)
        o = dup
        yield o
        o.freeze
      end

      def document_unique_identifying_string
        @existing_child_document_node.document_unique_identifying_string
      end

      attr_accessor(
        :existing_child_document_node,
        :existing_parent_document_node,
      )
    end
  end
end
# #history: born of pseudocode
