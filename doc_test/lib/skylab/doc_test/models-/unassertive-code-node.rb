module Skylab::DocTest

  class Models_::UnassertiveCodeNode # #[#025]

    class << self

      alias_method :via_runs_and_choices_, :new
      undef_method :new
    end  # >>

    def initialize discussion_run, code_run, choices
      @_choices = choices
      @_code_run = code_run
      @_discussion_run = discussion_run
    end

    def to_line_stream
      @_choices.particular_paraphernalia_for( self ).to_line_stream
    end

    def has_what_looks_like_a_variable_assignment
      idx = UnassertiveIndex___.new @_code_run
      @last_line_index___ = idx
      idx.__has_what_looks_like_a_variable_assignment
    end

    def to_code_run_line_object_stream
      @_code_run.to_line_object_stream
    end

    def to_particular_paraphernalia_of sym
      @_choices.particular_paraphernalia_of_for sym, self
    end

    def begin_description_string_session
      Models_::Description_String.via_discussion_run__ @_discussion_run, @_choices
    end

    def last_line_index___
      @last_line_index___
    end

    def is_assertive
      false
    end

    # ==

    class UnassertiveIndex___

      # look at every line of the "code run" searching for all lines that
      # match the pattern of a (straightforward) variable assignment.
      # memoize the matchdata and line number from each such line.

      def initialize c_r

        variable_assignment_lines = nil

        st = c_r.to_line_object_stream
        line_offset = -1
        begin
          lo = st.gets
          lo || break
          line_offset += 1
          lo.is_blank_line && redo
          md = RX___.match lo.string, lo.content_begin
          if md
            ( variable_assignment_lines ||= [] ).push VAL___[ md, line_offset ]
          end
          redo
        end while nil

        if variable_assignment_lines
          @__has_what_looks_like_a_variable_assignment = true
          @variable_assignment_lines = variable_assignment_lines
        end
      end

      RX___ = /\G(?<lvar>[_a-z][_a-zA-Z0-9]*)[ \t]*=[\t ]*/

      attr_reader(
        :__has_what_looks_like_a_variable_assignment,
        :variable_assignment_lines,
      )
    end

    # ==

    VAL___ = ::Struct.new :matchdata, :line_offset

  end
end
#history: subsumed "let assignment" and "before node"
