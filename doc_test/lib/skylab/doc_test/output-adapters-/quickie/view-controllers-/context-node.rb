module Skylab::DocTest

  module OutputAdapters_::Quickie

    class ViewControllers_::ContextNode  # #[#026]

      # this node is rife with comments, and all of it is EXPERIMENTAL
      # exactly as [#024] node theory.

      TEMPLATE_FILE___ = '_ctx.tmpl'

      def initialize para, cx
        @_common = para
        @_choices = cx
      end

      def to_line_stream

        # so a few things:
        #
        #   • our own line stream will be the output of our template,
        #     which will hopefully magically take care of indenting
        #     our body.
        #
        #   • we have a bunch of child "item" nodes: necessarily at least
        #     two, one example node and one unassertive code node per
        #     [#025]:axiom-1.
        #
        #   • our body should be the line stream from our item nodes,
        #     using "line stream via node stream" (covered by #file-2).
        #
        # some more detail:
        #
        #   • we need to figure out what our description line is.
        #
        #   • see next method

        ___index

        _p_a = remove_instance_variable :@_particular_array
        _n_st = Common_::Stream.via_nonsparse_array _p_a
        _body_line_st = Magnetics_::LineStream_via_NodeStream[ _n_st ]

        _d_s = remove_instance_variable :@__description_bytes

        # --

        t = @_choices.load_template_for TEMPLATE_FILE___

        t.set_simple_template_variable _d_s, :description_bytes

        t.set_multiline_template_variable _body_line_st, :context_body

        t.flush_to_line_stream
      end

      def ___index

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
        #
        # • BUT it may be that unassertive code blocks that don't match one
        #   or another hacky pattern are simply skipped over. yes, this for
        #   now..

        @_particular_array = []

        st = @_common.to_common_paraphernalia_stream

        @_see_unassertive = method :___see_first_unassertive

        begin
          common = st.gets
          common || break
          if common.is_assertive
            _accept common.to_particular_paraphernalia
            redo
          end
          @_see_unassertive[ common ]
          redo
        end while nil

        remove_instance_variable :@_see_unassertive
        NIL_
      end

      def ___see_first_unassertive unassa

        o = unassa.begin_description_string_session
        o.use_first_nonblank_line!
        o.remove_any_trailing_colons_or_commas!
        @__description_bytes = o.finish.inspect  # hm..

        @_see_unassertive = method :___see_subsequent_unassertive
        @_see_unassertive[ unassa ]
        NIL_
      end

      def ___see_subsequent_unassertive unassa

        if unassa.has_what_looks_like_a_variable_assignment
          _accept unassa.to_particular_paraphernalia_of :shared_subject
        else
          self._SHOULD_WARN
        end
      end

      def _accept common
        @_particular_array.push common ; nil
      end
    end
  end
end
