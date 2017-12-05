module Skylab::DocTest

  module OutputAdapters_::Quickie

    class DocumentWriteMagnetics_::Upgrade

      # #exactly #coverpoint5.4

      # "upgrade" an example node to be a context *document branch*.
      # (this will not carry over any of the body content of the former):
      #
      #   1. build an empty context node with the same identifying string.
      #
      #   1. get the existing (arbitrarily deep) margin of the document
      #      branch node we are replacing.
      #
      #   1. let the empty context node render itself to lines using
      #      this margin.
      #
      #   1. with these lines build a freeform branch document node.

      def initialize plan, cx, & p
        @_choices = cx
        @_listener = p
        @plan = plan
      end

      # this BOLD MOVE involves swapping-out one node for another in the
      # *document tree*, something we don't do anywhere else.

      def execute

        child = @plan.existing_node_index.existing_child_document_node

        child_ = __new_child_via child

        _parent = @plan.existing_node_index.existing_parent_document_node

        _parent.mutate_by_replacing_child__ child_, child

        child_
      end

      def __new_child_via child

        id_s = child.document_unique_identifying_string

        cn = Here_::ViewControllers_::ContextNode.empty_via__ id_s, @_choices

        _st = __map_lines cn

        _margin = child.nodes.first.get_margin
        _sym = cn.paraphernalia_category_symbol

        ErsatzParser::FreeformBranchFrame.oh_my _sym, _st, _margin do |vs|
          vs.document_unique_identifying_string = id_s
        end
      end

      # for those templates that correspond to branch-nodes our custom is that:
      #
      #   - their "body" section corresponds to a single template variable
      #     occurrence (as opposed to some looping idiom, which by the
      #     way does not exist in our templating solution)
      #
      #   - this variable name ends in `_body` or `_lines`
      #
      #   - this variable occurrence has a leading margin of whitespace
      #     before it that is meaningful
      #
      #   - this margin is nonzero length
      #
      #   - (this margin is spaces (not tabs))
      #
      #   - (this margin is two spaces)
      #
      # when the template renders the body section it can semi-magically
      # marginate all of its content (lines) using this arbitrary margin.
      #
      # now, when such a typical branch-node template gets rendered without
      # any body (constituent) nodes, you end up with a dangling
      # "margin line", which is a blank line with trailing whitespace
      # (i.e a line that blank but is of nonzero length, even after you
      # count the "LTS").
      #
      # for such cases, in the most typicial cases (but it depends on the
      # template) you end up with four lines in all:
      #
      #   1. an opening line with no indent
      #   2. a blank, zero-length line (it has only an LTS)
      #   3. a "margin line", and then
      #   4. the closing line.
      #
      # we may or may not leave the "margin line" intact, but below we
      # get a handle on it and assert the above assumption, in case we
      # want to do something with it.
      #
      # (current we *do* leave intact because we *do* use it at #spot1.6 eew)

      def __map_lines node

        lines = []
        st = node.to_line_stream( & @_listener )
        begin
          line = st.gets
          line || break
          md = BLANK_RX_ =~ line && ErsatzParser::MARGIN_RX.match( line )
          md && break
          lines.push line
          redo
        end while above

        md || self._SANITY_probably_OK_to_ignore_this_case

        lines.push line  # see what happens

        lines.push line while line = st.gets

        Stream_[ lines ]
      end
    end
  end
end
