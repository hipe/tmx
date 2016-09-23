module Skylab::DocTest

  module OutputAdapters_::Quickie

    class DocumentWriteMagnetics_::HybridSetup

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
        __this_first
        __this_second
        NIL
      end

      def __index

        # (there's not a real good reason we go from end to beginning any more)

        st = __reverse_stream
        stack = []
        begin
          match = st.gets
          match || break
          stack.push match
          redo
        end while above

        @_stack = stack ; nil
      end

      def __this_first

        _d = @_stack.last.line_offset

        otr = @unassertive_node.dup
        otr.variable_assignment_lines = nil

        cr = otr.code_run

        _lines_ = cr.lines_[ 0 ... _d ]
        _cr_ = cr.dup_via_lines__ _lines_
        otr.code_run = _cr_

        @on_const_definition[ otr ]
        NIL
      end

      def __this_second

        while match = @_stack.pop
          _pxy = Proxy__.new match, @choices
          @on_shared_subject[ _pxy ]
        end

        NIL
      end

      def __reverse_stream
        a = @unassertive_node.variable_assignment_lines
        Common_::Stream.via_range a.length - 1 .. 0 do |d|
          a.fetch d
        end
      end

      # ==

      class Proxy__

        def initialize match, cx
          @_cx = cx
          o = match.dup
          o.line_offset = 0
          @variable_assignment_lines = [ o ]
        end

        def to_particular_paraphernalia_under x
          _choices = remove_instance_variable :@_cx
          ViewControllers_::SharedSubject.via_three_ self, x, _choices
        end

        # -- all for the second proxy

        def to_code_run_line_object_stream
          Common_::Stream.via_item :xxxx  # not used
        end

        attr_reader(
          :variable_assignment_lines,
        )
      end
    end
  end
end
# #tombstone: `let` blocks, a primordial comment about intermediates
# #born of necessity
