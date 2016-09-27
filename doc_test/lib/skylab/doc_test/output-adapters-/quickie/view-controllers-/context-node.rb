module Skylab::DocTest

  module OutputAdapters_::Quickie

    class ViewControllers_::ContextNode  # #[#026]

      # this node is rife with comments, and all of it is #experimental
      # exactly as [#024] node theory.

      TEMPLATE_FILE___ = '_ctx.tmpl'

      class << self

        def via_two_ o, cx
          new.__init_by_two o, cx
        end

        def empty_via__ desc, cx
          new.__init_via_desc desc, cx
        end

        private :new
      end  # >>

      def __init_by_two gene, cx
        @_choices = cx
        _ = gene.to_stem_paraphernalia_stream
        __init_via_stem_paraphernalia_stream _
        self
      end

      def __init_via_desc desc, cx
        @_choices = cx
        @identifying_string = desc
        @description_bytes_ = desc.inspect  # #meh
        @_particular_array = EMPTY_A_
        self
      end

      def dup_by
        otr = dup
        yield otr
        otr
      end

      def particular_array= x
        @_particular_array = x
      end

      def identifying_string
        @identifying_string  # 5x
      end

      def UPGRADE_ITEM_NODE_TO_BE_EMPTY_BRANCH_NODE plan, & p
        DocumentWriteMagnetics_::Upgrade.new( plan, @_choices, & p ).execute
      end

      def to_branch_local_document_node_matcher

        mine = @identifying_string

        -> dn do

          if :context_node == dn.category_symbol

            _theirs = dn.document_unique_identifying_string
            mine == _theirs
          end
        end
      end

      #   - our own line stream will be the output of our template,
      #     which will magically take care of indenting our body.
      #
      #   - we have child "item" nodes: necessarily at least two, one
      #     example node and one unassertive code node per [#025]:axiom-1
      #
      #   - our body should be the line stream from our item nodes,
      #     using "line stream via node stream" (covered by #file-2).
      #
      #   - it's not a straightforward map-expand because of a few things:
      #
      #     - we need to figure out what our description line is from a child
      #     - (below)

      def to_line_stream & p

        n_st = to_particular_paraphernalia_stream

        # --

        body_line_st = AssetDocumentReadMagnetics_::LineStream_via_NodeStream[ n_st, & p ]

        # --

        t = @_choices.load_template_for TEMPLATE_FILE___

        t.set_simple_template_variable @description_bytes_, :description_bytes

        t.set_multiline_template_variable body_line_st, :context_body

        t.flush_to_line_stream
      end

      def to_particular_paraphernalia_stream
        Stream_[ @_particular_array ]
      end

        # here is at least one reason why we must peek the stream, and some
        # other reasons why we may want to:
        #
        # • although the template accepts a line stream for the body (which
        #   means that hypothetically we could stream over our items late
        #   for this rendering); we of course need all the template
        #   parameters to be assigned when we render, and one of these
        #   parameters is our own description bytes, and our description
        #   bytes are determined by a particular one of our items, and we
        #   don't know which one without in effect streaming through the
        #   stream ourselves (or we could cheat and use random access
        #   on the array of pairs, but that's ugly both because it makes
        #   this assumption about the internal representation and because
        #   we don't get to leverage paraphernalia by peeking it this early).
        #
        # • on that subject, an unassertive code node necessarily exists and
        #   necessarily has a discussion run and that run necessarily has a
        #   nonblank discussion line (if our logic is right). as far as we
        #   can tell right now we aren't using the discussion lines that
        #   appear above these unassertive nodes so they are available for
        #   use.
        #
        # • we allow for the possibility that what we do with unassertive
        #   code nodes will be context-dependent. we strongly discourage
        #   ourselves to require lookahead for this but maybe lookbehind.
        #
        # • all of this is belabored and overhthought anyway: in practice
        #   such phenomena should perhaps always exhibit the pattern:
        #
        #       SETUP, EXAMPLE, [ EXAMPLE, [..]]
        #
        #   in that order. but we make the implementation more lenient than
        #   that just so we don't have to raise syntax errors/warnings.
        #   (note we haven't had to model any yet.)
        #   (EDIT this is changing..)
        #
        # • BUT it may be that unassertive code blocks that don't match one
        #   or another hacky pattern are simply skipped over. yes, this for
        #   now..

      def __init_via_stem_paraphernalia_stream st

        @_particular_array = []

        @_on_assertive = :__on_assertive_normally
        @_on_unassertive = :__on_first_unassertive

        begin
          common = st.gets
          common || break
          if common.is_assertive
            send @_on_assertive, common
          else
            send @_on_unassertive, common
          end
          redo
        end while nil

        @_has_visible_setups = nil
        @_mutable_visible_setups = nil
        @_readable_visible_setups = nil
        remove_instance_variable :@_has_visible_setups
        remove_instance_variable :@_mutable_visible_setups
        remove_instance_variable :@_on_assertive
        remove_instance_variable :@_on_unassertive
        remove_instance_variable :@_readable_visible_setups
        NIL
      end

      def __on_first_unassertive unasser

        __init_description_bytes unasser
        @_on_unassertive = :__on_every_unassertive
        @_has_visible_setups = false
        send @_on_unassertive, unasser
        NIL
      end

      def __init_description_bytes unasser

        o = unasser.begin_description_string_session
        o.use_first_nonblank_line!
        o.remove_any_trailing_colons_or_commas!
        s = o.finish
        @identifying_string = s
        @description_bytes_ = s.inspect  # hm..
        NIL
      end

      def __on_every_unassertive unasser

        c_a = unasser.starts_with_what_looks_like_a_constant_assignment

        v_a = unasser.has_what_looks_like_a_variable_assignment

        if c_a
          if v_a
            __holy_smokes_you_want_both unasser  # #coverpoint5-2
          else
            _on_const_definition unasser
          end
        elsif v_a
          _on_shared_subject unasser
        else
          __when_neither unasser
        end

        # (we're calling this :#spot-5 - similiar elsewhere, might abstract)
        NIL
      end

      def __when_neither  unassa  # #not-covered

        # a code block with no magic - it is ignored! (used to fail)

        NOTHING_
      end

      def __holy_smokes_you_want_both unasser

        DocumentWriteMagnetics_::HybridSetup.by do |o|
          o.choices = @_choices
          o.on_const_definition = method :_on_const_definition
          o.on_shared_subject = method :_on_shared_subject
          o.unassertive_node = unasser
        end
        NIL
      end

      def _on_const_definition unasser

        o = unasser.to_particular_paraphernalia_of :const_definition
        if ! @_has_visible_setups
          @_has_visible_setups = true
          @_on_assertive = :__on_assertive_mapped_through_visible_setups
          @_mutable_visible_setups = MutableVisibleSetups___.new
        end
        @_readable_visible_setups = nil
        @_mutable_visible_setups.push_etc o
        _accept o
        NIL
      end

      def _on_shared_subject unasser
        if @_has_visible_setups
          _interpolate unasser
        else
          _ = unasser.to_particular_paraphernalia_of :shared_subject
          _accept _
        end
        NIL
      end

      def __on_assertive_mapped_through_visible_setups common
        _interpolate common
      end

      def _interpolate common
        @_readable_visible_setups ||= @_mutable_visible_setups.to_readable
        _ = common.to_particular_paraphernalia_under @_readable_visible_setups
        _accept _
        NIL
      end

      def __on_assertive_normally common
        _ = common.to_particular_paraphernalia
        _accept _
        NIL
      end

      def _accept common
        @_particular_array.push common ; nil
      end

      def paraphernalia_category_symbol
        :context_node
      end

      # === [#010]:B

      # ==

      class MutableVisibleSetups___

        def initialize
          @_visible_particulars = []
          @_cached_dootilies = []
        end

        def push_etc o
          @_visible_particulars.push o ; nil
        end

        def to_readable

          # the subject is a recording structure. rather than being "finished"
          # at any discrete point, we allow a "readable" (frozen) form of it
          # to spawn off at any point..

          cooked = @_cached_dootilies
          raw = @_visible_particulars
          if cooked.length == raw.length
            @__last_readable
          else
            ( cooked.length ... raw.length ).each do |d|
              cooked[ d ] = raw.fetch(d).to_mapper__
            end
            x = ReadableVisibleSetups__.new cooked.dup.freeze  # think
            @__last_readable = x
            x
          end
        end
      end

      # ==

      class ReadableVisibleSetups__

        def initialize a
          if 1 != a.length
            self._ANNOYING_multiple_visible_shared_setups
          end
          @__p = a.fetch 0
        end

        def map_body_line_stream st
          @__p[ st ]
        end
      end
    end
  end
end
