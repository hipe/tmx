module Skylab::Brazen

  class CollectionAdapters::GitConfig

    module Mutable  # intro to this sizeable sub-project at [#008]

      class << self

        def parse_document_by
          This_::Magnetics_::MutableDocument_via_Parameters.call_by do |o|
            yield o
          end
        end

        def new_empty_document

          This_::Magnetics_::MutableDocument_via_Parameters.call_by do |o|
            o.byte_upstream_reference = EmptyByteUpstreamReference___.new
          end
        end
      end  # >>

      # ==

      class BlankLine_or_CommentLine_

        def initialize frozen_line
          @_frozen_line = frozen_line
          freeze
        end

        def unparse_into y
          y << @_frozen_line
        end

        def TO_LINE_AS_BLANK_LINE_OR_COMMENT_LINE  # [cu]
          @_frozen_line
        end

        def to_line_as_atom_
          @_frozen_line
        end

        def _category_symbol_
          NOTHING_  # until one is needed
        end

        # ~ ( [cu]

        def is_section_or_subsection
          FALSE
        end
        def is_assignment
          FALSE
        end
        def is_blank_line_or_comment_line
          TRUE
        end

        # ~ )

        def _is_atom_
          TRUE
        end
      end

      # ==

      module TheSkipAndWhineMethods_

        def skip_else_ ivar=nil, rx
          if skip_ ivar, rx
            ACHIEVED_
          else
            yield
          end
        end

        def skip_ ivar=nil, rx
          d = @_scn_.skip rx
          if d
            if ivar
              instance_variable_set ivar, d
            end
            @_column_offset_ += d ; ACHIEVED_
          end
        end

        def whine_ sym
          @client.receive_error_symbol_and_column_number_ sym, @_column_offset_ + 1
          UNABLE_
        end
      end

      # ==

      class EmptyByteUpstreamReference___

        def initialize
          @__fake_IO = THE_EMPTY_BYTE_UPSTREAM___
        end

        def TO_REWOUND_SHAREABLE_LINE_UPSTREAM_EXPERIMENT
          # (we know it won't be re-used, for now..)
          # (but if it were it would be no problem to)
          remove_instance_variable :@__fake_IO
        end
      end

      module THE_EMPTY_BYTE_UPSTREAM___ ; class << self
        def gets
          NOTHING_
        end
      end ; end

      # ==

      DereferenceElement_via_NormalName_and_Collection_ = -> norm_sym, perf do
        el = perf._lookup_softly_no_unwrap_ norm_sym
        if el
          el.value_as_result_of_dereference_or_lookup_softy_
        else
          self._COVER_ME__etc_easy__
        end
      end

      LookupElementSoftlyNoUnwrap_via_NormalName_and_RelevantStream_ = -> norm_sym, st do
        begin
          el = st.gets
          el || break
        end until norm_sym == el.external_normal_name_symbol
        el
      end

      # ==

      Deeply_duplicate_elements_ = -> orig_a do  # only used in testing
        new_a = ::Array.new orig_a.length
        orig_a.each_with_index do |x, d|
          new_a[d] = orig_a.fetch( d )._DEEPLY_DUPLICATE_
        end
        new_a
      end

      # ==

      POLYADIC_EMPTINESS_ = -> * { NOTHING_ }
      RX_ASSIGNMENT_NAME_ = /[A-Za-z][-0-9A-Za-z]*/
      RX_SECTION_NAME_ = /[-A-Za-z0-9.]+/
      RX_SPACE_ = /[ ]*/
      This_ = self

      # ==
      # ==
    end
  end
end
# #history-A: massive breaking out of tons of nodes into their own files.h
