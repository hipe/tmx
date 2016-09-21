module Skylab::DocTest

  class ErsatzParser

      # (try to generalize the dark hack of [#sy-034].)
      #
      # called "ersatz" because this is fundamentally a hack :[#002];
      # that is, no matter how good a job we do here we will never be
      # able to scale to all documents by parsing by-hand like this
      # while tokenizing on lines, nor should we want to. this is just
      # a stand-in for the proof of concept of it all (the dream of [cm]).

      class << self
        alias_method :begin, :new
        undef_method :new
      end  # >>

      def initialize
        @branch_nonterminals = []
        @__default_branch_end_matcher_builder_is_not_set = nil
      end

      # -- mutation

      def default_branch_end_line_matcher_by & p

        remove_instance_variable :@__default_branch_end_matcher_builder_is_not_set
        @default_branch_end_matcher_builder = p ; nil
      end

      def add_branch_line_matcher mr, sym=:branch, & id_s_p
        @branch_nonterminals.push(
          NonTerminal___.new( mr, sym, @default_branch_end_matcher_builder, id_s_p )
        )
      end

      def finish
        @branch_nonterminals.freeze
        freeze
      end

      # --

      def parse_string s, & x_p
        parse_line_stream Home_.lib_.basic::String.line_stream( s ), & x_p
      end

      def parse_line_stream st, & x_p
        Parse___.new( st, self, & x_p ).execute
      end

      attr_reader(
        :branch_nonterminals,
        :default_branch_end_matcher_builder,
      )

      # ==

      class Parse___

        def initialize st, g, & oes_p
          @_branch_nonterminals = g.branch_nonterminals
          @_default_branch_end_matcher_builder = g.default_branch_end_matcher_builder
          @_line_stream = st
          @__on_event_selectively = oes_p  # any
        end

        def execute

          @_lineno = 0
          @_stack = [ RootFrame___.new ]
          @_state = :_process_line_from_root_context

          begin
            line = @_line_stream.gets
            line || break
            @_lineno += 1
            @_line = line
            send @_state
            redo
          end while nil

          if 1 == @_stack.length
            @_stack.first.close_branch_frame
          else
            # (since you cannot pop from root #here, if the stack depth
            # is not one then it's more than one.)
            ___when_ending_line_not_found
          end
        end

        def ___when_ending_line_not_found

          node = @_stack.last
          line_string = node.nodes.first.line_string
          lineno = node.lineno
          total_lines = @_lineno

          ev = Common_::Event.inline_not_OK_with(
            :parse_error,
            :lineno, lineno,
            :line, line_string,
            :error_subcategory, :ending_line_not_found,
            :exception_class_by, -> do
              ParseError
            end

          ) do |y, o|

            y << "hack failed: couldn't find end line for node opened on line #{ lineno }\n"
            y << "  line #{ lineno }: #{ line_string.inspect }\n"
            y << "  (#{ total_lines } lines in file.)\n"
          end

          oes_p = @__on_event_selectively

          if oes_p
            oes_p.call :error, :parse_error do
              ev
            end
            UNABLE_
          else
            raise ev.to_exception
          end
        end

        # -- the central "algorithm"
        #
        # we tokenize on lines. we push when we see a line that looks like
        # it opens a "branch" node. we pop when a line looks like it closes
        # that branch node (according to the branch node).
        #
        #   • the logic is slightly different when in the root context
        #     because we aren't scanning for an end token.
        #
        #   • the blank line check is an "optimization" - we assume that
        #     blank lines never push or pop anything

        def _process_line_from_root_context

          if BLANK_RX_ =~ @_line
            _add_blank_line
          elsif _line_matches_branch_nonterminal
            __push_from_root_context
          else
            _add_nonblank_line
          end
          # (note you cannot pop from the root context (assumed by #here))
          NIL_
        end

        def __main

          if BLANK_RX_ =~ @_line
            _add_blank_line
          elsif _line_matches_branch_nonterminal
            __push_normal
          elsif @_stack.last.__line_matches_end @_line
            __pop
          else
            _add_nonblank_line
          end
          NIL_
        end

        def __push_from_root_context
          @_state = :__main
          _push
        end

        def __push_normal
          # (hi.)
          _push
        end

        def _push

          frame = NonRootFrame___.new(
            remove_instance_variable( :@_matchdata ),
            remove_instance_variable( :@_branch_nonterminal ),
            @_lineno,
          )
          @_stack.push frame
          _add_nonblank_line
          NIL_
        end

        def __pop
          # the top of the stack matches the current line.
          __add_ending_line
          _frame = @_stack.pop
          @_stack.last.__add_completed_branch_frame _frame
          if 1 == @_stack.length
            @_state = :_process_line_from_root_context
          end
          NIL_
        end

        def _line_matches_branch_nonterminal

          md = nil
          bnt = @_branch_nonterminals.detect do |bnt_|
            md = bnt_.match @_line  # eek
          end

          if bnt
            @_branch_nonterminal = bnt
            @_matchdata = md
            ACHIEVED_
          else
            UNABLE_
          end
        end

        def _add_blank_line
          @_stack.last.add_blank_line remove_instance_variable :@_line ; nil
        end

        def __add_ending_line
          @_stack.last.add_ending_line remove_instance_variable :@_line ; nil
        end

        def _add_nonblank_line
          @_stack.last.add_nonblank_line remove_instance_variable :@_line ; nil
        end
      end

      # ==

      class NonTerminal___

        def initialize mr, sym, end_matcher_builder, id_s_p
          @begin_matcher = mr
          @category_symbol = sym
          @_end_matcher_builder = end_matcher_builder
          @identifying_string_proc = id_s_p  # optional
        end

        def __build_end_line_matcher md
          @_end_matcher_builder.call md
        end

        def match line
          @begin_matcher.match line
        end

        attr_reader(
          :category_symbol,
          :identifying_string_proc,
        )
      end

      # ==

      class BranchNode__

        # -- mutators

        def begin_insert_into_empty_branch_session
          Home_::TestDocumentMutationMagnetics_::Insertion_via_NewNodes::Begin_insert_into_empty[ @nodes ]
        end

        def replace__ a  # freezes
          @nodes = a.frozen? ? a : a.dup.freeze ; nil
        end

        # -- readers

        def to_line_stream
          Home_::TestDocumentReadMagnetics_::LineStream_via_BranchNode[ self ]
        end

        def first_qualified_example_node_with_identifying_string s

          to_qualified_example_node_stream.flush_until_detect do |qeg|

            s == qeg.example_node.identifying_string
          end
        end

        def first_example_node  # #testpoint-only, #todo too high here

          to_qualified_example_node_stream.gets.example_node
        end

        def to_qualified_example_node_stream

          o = _begin_branch_stream_session

          o.branch_stream.map_reduce_by do |branch|

            if :example_node == branch.category_symbol
              Qualified_Example___[ branch, o.current_parent_branch__ ]
            end
          end
        end

        Qualified_Example___ = ::Struct.new :example_node, :parent_branch

        def to_branch_stream
          _begin_branch_stream_session.branch_stream
        end

        def _begin_branch_stream_session
          Home_::TestDocumentReadMagnetics_::BranchStream_via_BranchNode.begin_for__ self
        end

        def only_one * sym_a, & l
          x = self
          sym_a.length.times do |d|
            x = x.__only_one_via_category_symbol sym_a.fetch d do |*i_a, &ev_p|
              __maybe_contextualize_error d, sym_a, ev_p, i_a, l
            end
          end
          x
        end

        def __maybe_contextualize_error d, sym_a, ev_p, i_a, l
          l ||= -> *, & ev_p_ do
            raise ev_p_[].to_exception
          end
          if d.zero?
            l[ * i_a, & ev_p ]
          else
            l.call( * i_a ) do
              _orig_em = ev_p[]
              _e = _orig_em.to_exception
              _e_ = _e.with_path sym_a[0..d]
              _e_.to_wrapped_exception
            end
          end
        end

        def __only_one_via_category_symbol sym, & l

          a = __all_via_category_symbol sym
          if 1 == a.length
            a.fetch 0
          else
            l.call :error, :exception, :failed_assumption do
              _e = FailedAssumption.new [sym], "expected 1 had #{ a.length } node(s)"
              _e.to_wrapped_exception
            end
            UNABLE_
          end
        end

        def first_via_category_symbol sym
          _to_stream_of( sym ).gets
        end

        def __all_via_category_symbol sym
          _to_stream_of( sym ).to_a
        end

        def _to_stream_of sym
          to_immediate_child_node_stream.reduce_by do |no|
            sym == no.category_symbol
          end
        end

        def to_immediate_child_node_stream
          Common_::Stream.via_nonsparse_array @nodes
        end

        def to_immediate_child_scanner
          Common_::Polymorphic_Stream.via_array @nodes
        end

        attr_reader(
          :category_symbol,
          :nodes,
        )

        def is_branch
          true
        end
      end

      class FreeformBranchFrame < BranchNode__  # 1x

        def initialize sym, eg, nodes
          @category_symbol = sym
          @identifying_string = eg.identifying_string
          @nodes = nodes
        end

        attr_reader(
          :identifying_string,
        )
      end

      class BranchNode_from_Document__ < BranchNode__

        def initialize
          @_branch_stack = nil
          @nodes = []
        end

        # -- initialization-time mutators

        def __add_completed_branch_frame fr
          o = fr.close_branch_frame
          ( @_branch_stack ||= [] ).push @nodes.length
          @nodes.push o ; nil
        end

        def close_branch_frame

          # whenever a branch node receives its "close" expression
          # it knows it's not getting any more children.

          stack = remove_instance_variable :@_branch_stack
          if stack
            st = Common_::Stream.via_range stack.length-1..0 do |d|
              @nodes.fetch stack.fetch d
            end
            right = st.gets
            middle = st.gets  # might be nil
            # right.receive_previous_and_next middle, NOTHING_
            if middle
              begin
                left = st.gets  # might be nil
                # middle.receive_previous_and_next left, right
                left || break
                right = middle
                middle = left
                redo
              end while nil
            end
          end
          @nodes.freeze
          self  # don't freeze yet, we don't have prev and next
        end

        def add_blank_line s
          @nodes.push Line_.new s, :blank_line ; nil
        end

        def add_ending_line s
          @nodes.push Line_.new s, :ending_line ; nil
        end

        def add_nonblank_line s
          @nodes.push Line_.new s, :nonblank_line ; nil
        end

        # -- work-time mutators

        def begin_insert_into_empty_document_given choices
          choices.begin_insert_into_empty_document self
        end

        def prepend_example_before_some_existing_examples__ eg
          @nodes = Home_::TestDocumentMutationMagnetics_::Insertion_via_NewNodes::Prepend_before_some_existing[ eg, @nodes ]
          NIL_
        end

        def insert_example_after__ after_this_eg, eg
          @nodes = Home_::TestDocumentMutationMagnetics_::Insertion_via_NewNodes::Insert_after[ after_this_eg, eg, @nodes ]
          NIL_
        end

        def replace_lines line_st

          o = Home_::TestDocumentMutationMagnetics_::NewNodes_via_LineStream_and_OriginalNodes.begin
          o.line_stream = line_st
          o.original_nodes = @nodes
          o.do_replace_constituent_lines = false
          _etc o
        end

        def replace_constituent_lines line_st

          o = Home_::TestDocumentMutationMagnetics_::NewNodes_via_LineStream_and_OriginalNodes.begin
          o.line_stream = line_st
          o.original_nodes = @nodes
          o.do_replace_constituent_lines = true
          _etc o
        end

        def _etc o
          a = o.finish
          3 <= a.length || ::Home_._SANITY
          @nodes = a
          NIL_
        end
      end

      class RootFrame___  < BranchNode_from_Document__

        def write_lines_into y  # #testpoint-only (for now)
          st = to_line_stream
          begin
            line = st.gets
            line or break
            y << line
            redo
          end while nil
          y
        end
      end

      class NonRootFrame___ < BranchNode_from_Document__

        def initialize md, bnt, lineno_d
          @_branch_NT = bnt
          @category_symbol = bnt.category_symbol
          @_end_line_matcher = bnt.__build_end_line_matcher md
          @lineno = lineno_d
          @_matchdata = md  # just for id s
          super()
        end

        def __line_matches_end line
          @_end_line_matcher =~ line
        end

        def close_branch_frame
          remove_instance_variable :@_end_line_matcher
          super()
        end

        def identifying_string  # assume a proc exists to determine any it
          @_id_s_kn ||= __build_identifying_string_knownness
          @_id_s_kn.value_x
        end

        def __build_identifying_string_knownness
          Common_::Known_Known[
            @_branch_NT.identifying_string_proc[ @_matchdata ] ]
        end

        attr_reader(
          :lineno,
        )
      end

      # ==

      class Line

        def initialize s, sym
          @category_symbol = sym
          @line_string = s
        end

        def get_margin
          MARGIN_RX___.match( @line_string )[ 0 ]
        end

        MARGIN_RX___ = /\A[\t ]*/

        def is_blank_line
          BLANK_RX_ =~ @line_string
        end

        attr_reader(
          :category_symbol,
          :line_string,
        )

        def is_branch
          false
        end
      end

      # ==

      class FailedAssumption < ::RuntimeError

        def initialize sym_a, msg
          @symbol_array = sym_a
          @_message_stem = msg
          super "#{ msg } for #{ sym_a.inspect }"
        end

        def with_path sym_a
          self.class.new sym_a, @_message_stem
        end

        def to_wrapped_exception
          WrappedException___.new self
        end

        attr_reader(
          :symbol_array,
        )
      end

      WrappedException___ = ::Struct.new :to_exception
        # (future-proof ourselves the possibility of emitting events)

      # ==

      Here_ = self
      Line_ = Line
      ParseError = ::Class.new ::RuntimeError
  end
end
# #tombstone: previous and next
