module Skylab::DocTest

  module OutputAdapters_::Quickie

    class DocumentWriteMagnetics_::HybridSetup

      # when an unassertive code run has ONE (at least?) const definition
      # and ONE OR MORE assignment "lines",
      #
      #   A) broadly, separate (at least) the expression of const
      #      assignments and the expression of shared subjects.
      #
      #   B) where we express shared subjects, be sure that we express
      #      every line of an assignment expression whose right hand side
      #      spans multiple lines (hackishly).
      #
      #   C) for now we'll try to make it so that all shared subject lines
      #      are expressed collectively as one shared subject assignment.
      #      (really, we just want it to do exactly what would happen if it
      #      were a normal shared subject declaration, which is why we send
      #      custom proxies to the nodes that express those normally.)

      class << self
        def by
          o = new
          yield o
          o.execute
        end
        private :new
      end  # >>

      attr_writer(
        :choices,
        :on_const_definition,
        :on_shared_subject,
        :unassertive_node,
      )

      def execute
        __index
        __express_const_definition
        __express_shared_subjects
        NIL
      end

      def __express_const_definition

        otr = @unassertive_node.dup
        otr.variable_assignment_lines = nil

        cr = otr.code_run

        _lines_ = cr.lines_[ 0 ... @__line_offset_of_first_assignment ]
        _cr_ = cr.dup_via_lines__ _lines_
        otr.code_run = _cr_

        @on_const_definition[ otr ]
        NIL
      end

      def __express_shared_subjects

        vals = @unassertive_node.variable_assignment_lines

        subtract_this = vals[ 0 ].line_offset

        _vals_ = vals.map do |sct|
          sct_ = sct.dup
          sct_.line_offset -= subtract_this
          sct_
        end

        _code_lines = @unassertive_node.code_run.lines_

        _code_lines_ = _code_lines[ subtract_this .. -1 ]

        _proxy = ToPartiParaphernUnderProxy___.new _vals_, _code_lines_, @choices

        @on_shared_subject[ _proxy ]

        NIL
      end

      def __index
        a = @unassertive_node.variable_assignment_lines
        # --
        @__line_offset_of_first_assignment = a.first.line_offset
        NIL
      end

      # ==

      class ToPartiParaphernUnderProxy___

        def initialize vals, code_lines, cx
          @__choices = cx
          @__code_lines = code_lines
          @__VALs = vals
        end

        def to_particular_paraphernalia_under visible_shared

          _stem_proxy = StemProxy___.new @__VALs, @__code_lines

          Here_::ViewControllers_::SharedSubject.via_three_(
            _stem_proxy, visible_shared, @__choices )
        end
      end

      # ==

      class StemProxy___

        def initialize vals, cls
          @__code_lines = cls
          @__VALs = vals
        end

        def to_code_run_line_object_stream
          Stream_[ @__code_lines ]
        end

        def variable_assignment_lines
          @__VALs
        end
      end

      # ==
    end
  end
end
# #tombstone (temporary): the older new way (possibly not covered)
# #tombstone: `let` blocks, a primordial comment about intermediates
# #born of necessity
