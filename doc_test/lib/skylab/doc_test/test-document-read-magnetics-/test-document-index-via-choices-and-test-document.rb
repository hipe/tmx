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
        @root_context_node = rcn
        @test_document = td
        @__universal_name_box = unb
      end

      def lookup_via_identifying_string k
        @__universal_name_box.h_[ k ]
      end

      attr_reader(
        :branch_index,
        :root_context_node,
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
          no = scn.current_token

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
        context: :__index_a_context_node,
        ending_line: :__ending_line_is_noop,
        example_node: :__index_an_example_node,
        nonblank_line: :__probably_dont_index_a_nonblank_line,
      }

      def __maybe_index_a_before_node no
        if ALL___ == no.identifying_string
          __index_before_all no
        else
          self._COVER_ME_before_each_do_nothing
          ACHIEVED_
        end
      end
      ALL___ = 'all'

      def __index_before_all no
        if @_seen_a_before_all_block
          self._COVER_ME_fail_softly
        else
          @_seen_a_before_all_block = true
          @__before_all_block = no
          @_node_indexes_of_interest.push :_placeholder_for_before_all
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
            @_universal_name_box.replace tmp.identifying_string, bi
          else
            ok = bi
          end
        end
        ok
      end

      def __index_an_example_node no

        _ni = ExistingExampleNodeIndex___.new do |o|
          o.existing_child_document_node = no
          o.existing_parent_document_node = @_branch_docnode
        end

        ok = _add_to_universal_name_index _ni
        ok and @_node_indexes_of_interest.push :_yizzy_an_example_
        ok
      end

      def __probably_dont_index_a_nonblank_line _
        ACHIEVED_
      end

      def __ending_line_is_noop _
        ACHIEVED_
      end

      def _add_to_universal_name_index node_index

        k = node_index.identifying_string
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

      def initialize bab, nioi, dn
        if bab
          @has_before_all = true
          @before_all_block = bab
        end
        @existing_document_node = dn
        @node_indexes_of_interest = nioi
      end

      attr_reader(
        :existing_document_node,
        :before_all_block,
        :has_before_all,
        :node_indexes_of_interest,
      )

      def is_of_branch
        true
      end
    end

    # ==

    class ExistingNodeIndex__

      def initialize
        yield self
        freeze
      end

      def identifying_string
        @existing_child_document_node.identifying_string
      end

      attr_accessor(
        :existing_child_document_node,
        :existing_parent_document_node,
      )
    end

    class ExistingExampleNodeIndex___ < ExistingNodeIndex__
      def is_of_branch
        false
      end
    end

    class TemporaryBranchNodeIndex___ < ExistingNodeIndex__
      def is_of_branch
        true
      end
    end
  end
end
# #history: born of pseudocode
