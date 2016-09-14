module Skylab::DocTest

  class Models_::UnassertiveCodeNode  # notes in #[#025]

    class << self

      alias_method :via_runs_and_choices_, :new
      undef_method :new
    end  # >>

    def initialize discussion_run, code_run, test_file_context_p, choices
      @_choices = choices
      @_code_run = code_run
      @_discussion_run = discussion_run
      @_do_index_features = true
      @test_file_context_proc__ = test_file_context_p
    end

    def to_line_stream
      @_choices.particular_paraphernalia_for( self ).to_line_stream
    end

    def starts_with_what_looks_like_a_constant_assignment
      @_do_index_features && _index_features
      @starts_with_what_looks_like_a_constant_assignment
    end

    def const_assignment_line_match  # assume above
      @const_assignment_line_match
    end

    def has_what_looks_like_a_variable_assignment
      @_do_index_features && _index_features
      @has_what_looks_like_a_variable_assignment
    end

    def variable_assignment_lines  # assume above
      @variable_assignment_lines
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

    def _index
      @last_line
    end

    def _index_features
      @_do_index_features = false
      Index_features___.new( self, @_code_run ).execute
      NIL
    end

    def _feature_index
      @___feature_index ||=  UnassertiveIndex___.new @_code_run
    end

    def feature_index__  # as an assertion
      @___feature_index
    end

    attr_reader(
      :test_file_context_proc__
    )

    def is_assertive
      false
    end

    # ==

    class Index_features___

      # with an ad-hoc hand-written parser, scan over each line of the
      # "code run" hackishly looking for these features:
      #
      #   - does the first content line look like a constant assignment?
      #
      #   - look for every every content line that matches the pattern of
      #     a straightforward variable assignment. memoize the matchdata
      #     and line offset for each such line.
      #
      # results of the parse are written as ivars to the parameter store.

      def initialize parameter_store, code_run
        @code_run = code_run
        @parameter_store = parameter_store
      end

      def execute

        __init_line_scanning

        _advance_to_any_next_nonblank_line

        if @_has_current_line
          __parse_content
        end

        freeze
      end

      def __parse_content  # assume has current, nonblank line

        a = nil

        if __line_looks_like_constant_assignment
          starts_etc = true
          _assign _release_match_in_line, :@const_assignment_line_match
          _advance_to_any_next_nonblank_line
        end

        while @_has_current_line  # for each remaining content line

          if __line_looks_like_assignment_line
            ( a ||= [] ).push _release_match_in_line
          end

          _advance_to_any_next_nonblank_line
        end

        if a
          has_etc = true
          _assign a.freeze, :@variable_assignment_lines
        end

        _assign starts_etc, :@starts_with_what_looks_like_a_constant_assignment
        _assign has_etc, :@has_what_looks_like_a_variable_assignment

        NIL
      end

      def _assign x, ivar
        @parameter_store.instance_variable_set ivar, x ; nil
      end

      def __line_looks_like_constant_assignment
        _match CONSTANT_ASSIGNMENT_RX___
      end

      const_rxs = '[A-Z][a-zA-Z_0-9]*'

      CONSTANT_ASSIGNMENT_RX___ = /\G
        (?:
          (?: module | class ) [ ] (?<const> #{ const_rxs } )
        |
          (?<const> #{ const_rxs } )[ \t]*=[^=>]
        )
      /x
      # #note-1

      def __line_looks_like_assignment_line
        _match ASSIGNMENT_RX___
      end

      ASSIGNMENT_RX___ = /\G(?<lvar>[_a-z][_a-zA-Z0-9]*)[ \t]*=[^=>]/ # #note-1

      def _match rx
        @_matchdata = rx.match @_line.string, @_line.content_begin
        @_matchdata ? ACHIEVED_ : UNABLE_
      end

      def _release_match_in_line
        _md = remove_instance_variable :@_matchdata
        MatchInLine___[ _md, @_line_offset ]
      end

      def _advance_to_any_next_nonblank_line
        begin
          @__advance_to_any_next_line.call
        end while @_has_current_line && @_line.is_blank_line
        NIL
      end

      def __init_line_scanning

        @_line_offset = -1
        @_has_current_line = true

        line_object_stream = @code_run.to_line_object_stream

        @__advance_to_any_next_line = -> do
          @_line = line_object_stream.gets
          if @_line
            @_line_offset += 1
          else
            @_has_current_line = false
          end
          NIL
        end
        NIL
      end
    end

    # ==

    MatchInLine___ = ::Struct.new :matchdata, :line_offset

  end
end
#history: subsumed "let assignment" and "before node"
