module Skylab::Brazen

  module CollectionAdapters::GitConfig

    module Mutable

      class Magnetics_::MutableDocument_via_Parameters < CommonDocumentParse_

        def init_for_parse_
          @scn = Home_.lib_.string_scanner.new EMPTY_S_
          @_peeker = :_build_reusable_peeker
          super
        end

        def init_appropriate_document_instance_

          @document = MutableDocument___.new @byte_upstream_reference
          @current_nonterminal_node = @document ; nil
        end

        def execute_parse_

          ok = ACHIEVED_
          io = @byte_upstream_reference.TO_REWOUND_SHAREABLE_LINE_UPSTREAM_EXPERIMENT

          begin
            @line = io.gets
            @line || break
            @lineno += 1

            if BLANK_LINE_OR_COMMENT_RX_ =~ @line
              @current_nonterminal_node.accept_blank_line_or_comment_line_ @line.freeze
              redo
            end
            @scn.string = @line
            ok = send @state_symbol
          end while ok

          ok and remove_instance_variable :@document
        end

        # the next two methods correspond to the two states described
        # at [#008.D]: either we're expecting definitely a section line,
        # or it's either a section line or an assignment line and we don't
        # know which.

        def when_before_section_  # the starting state (only), set by parent

          sect = Magnetics_::Section_or_Subsection_via_Client.call_by do |o|
            o.will_parse_expecting_a_section_line_not_an_assignment_line__
            o.client = self
          end

          sect and accept_section_ sect
        end

        def when_section_or_assignment_

          # as described in [#same] above, we don't know yet whether this is
          # a section line or an assignment line. probably because an open
          # square bracket is so distinctive, we first "peek" if the current
          # line looks like it is a section line, and if it looks like it is
          # we continue trying to parse it as one; otherwise we assume it is
          # an assignment line and attempt to parse it as one. :[#008.E]

          # it's convenient to do this "peeking" with a performer that has
          # state that it holds on to to continue the parse with when it
          # matches. because OCD, if we discover that this line is not a
          # section line then we will re-use this same "peeker" for the next
          # time so BE CAREFUL.

          perf = send @_peeker  # because OCD we re-use the same "peeker"
          if perf.parse_the_beginning_of_the_line__
            __release_peeker
            sect = perf.parse_the_rest_of_the_line__
            sect and accept_section_ sect
          else
            asmt = Magnetics_::Assignment_via_Client[ self ]
            asmt and accept_assignment_ asmt
          end
        end

        def _build_reusable_peeker

          perf = Magnetics_::Section_or_Subsection_via_Client.call_by do |o|
            o.client = self
          end

          @_peeker_instance = perf
          @_peeker = :__use_peeker_on_deck
          send @_peeker
        end

        def __use_peeker_on_deck
          @_peeker_instance
        end

        def __release_peeker
          @_peeker = :_build_reusable_peeker
          remove_instance_variable :@_peeker_instance
          NIL
        end

        def accept_assignment_ asmt
          @current_nonterminal_node.accept_assignment_ asmt
          ACHIEVED_  # convenience
        end

        def accept_section_ sect
          @document.accept_section_ sect
          @current_nonterminal_node = sect
          @state_symbol = :when_section_or_assignment_
          ACHIEVED_  # convenience
        end

        def _accept_BUR x
          @byte_upstream_reference = x ; nil
        end

        def accept_string_for_immediate_scan s
          @scn = Home_.lib_.string_scanner.new s ; nil
        end

        def string_scanner_for_current_line_
          @scn
        end
      end

      # ==

      class MutableDocument___

        def initialize bur
          @document_byte_upstream_reference = bur
          @_elements_ = []
        end

        # ~ ( avoid accidentally calling these - use the custom ones below #here1
        undef_method :dup
        private :freeze
        # ~ )

        # -- write

        def accept_section_ sect
          @_elements_.push sect
          ACHIEVED_  # #covenience
        end

        def add_comment str
          str.include? NEWLINE_ and self._COVER_ME__this_is_for_single_line_comments_only__
          accept_blank_line_or_comment_line_ "# #{ str }#{ NEWLINE_ }".freeze
          ACHIEVED_
        end

        def accept_blank_line_or_comment_line_ frozen_line
          @_elements_.push BlankLine_or_CommentLine_.new frozen_line
          NIL
        end

        # -- read

        def to_section_stream  # seems to be a thing, #cov2.2
          sections.to_stream_of_sections
        end

        def sections
          @___sections_facade ||= This_::Models_::MutableSectionOrSubsection::SectionsFacade.new @_elements_
        end

        def write_to_path_by  # #cov1.3

          This_::Magnetics::WriteDocument_via_Collection.call_by do |o|
            yield o
            o.line_upstream = to_line_stream
          end
          # always succeeds. failure is impossible
        end

        def unparse
          write_bytes_into ""
        end

        def write_bytes_into y
          @_elements_.each do |el|
            el.write_bytes_into y
          end
          y
        end

        def to_line_stream

          scn = Scanner_[ @_elements_ ]

          p = nil ; main = -> do

            if scn.no_unparsed_exists
              p = EMPTY_P_ ; NOTHING_
            else
              el = scn.gets_one
              if el._is_atom_
                el.to_line_as_atom_
              else
                st = el.to_line_stream_as_section__
                p = -> do
                  line = st.gets
                  if line
                    line
                  else
                    p = main
                    p[]
                  end
                end
                p[]
              end
            end
          end
          p = main

          Common_.stream do
            p[]
          end
        end

        def description_under expag
          self._COVER_ME__this_used_to_be_this__
          @document_byte_upstream_reference.description_under expag
        end

        def DOCUMENT_IS_EMPTY  # [cu] only. meh
          @_elements_.length.zero?
        end

        attr_reader(
          :document_byte_upstream_reference,
        )

        def freeze_as_mutable_document___  # #testpoint only. :#here1
          @_elements_.each( & :_FREEZE_AS_DOCUMENT_ELEMENT_ )
          @document_byte_upstream_reference.freeze
          freeze
        end

        def DUPLICATE_DEEPLY_AS_MUTABLE_DOCUMENT_  # #testpoint only
          otr = self.class.allocate
          otr.instance_variable_set :@_elements_, @_elements_.map( & :_DUPLICATE_DEEPLY_ )
          otr
        end
      end

      # ==
    end
  end
end
# #history-A: broke out of central "mutable" node (spiritually) during heavy refactor
