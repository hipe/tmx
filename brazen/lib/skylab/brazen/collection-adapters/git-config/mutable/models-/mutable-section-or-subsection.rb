module Skylab::Brazen

  module CollectionAdapters::GitConfig

    module Mutable

      class Models_::MutableSectionOrSubsection < Common_::SimpleModel

        # -

        class SectionsFacade  # 1x

          # (façades are explained at [#008.F])

          def initialize a
            @_all_elements_ = a
          end

          # -- write

          def delete_sections_via_sections a  # [cu], also #cov2.2

            This_::Magnetics::DeleteEntity_via_Entity_and_Collection.call_by do |o|
              o.will_delete_these_actual_instances a
              o.all_elements = @_all_elements_
            end
            # result is a (different) array of the deleted items
          end

          def touch_section subsect_s=nil, sect_s, & p

            sect = build_section_by_ do |o|
              o.unsanitized_subsection_name_string = subsect_s  # nil OK
              o.unsanitized_section_name_string = sect_s
              o.listener = p
            end

            if sect
              __do_touch_section p, sect
            else
              sect
            end
          end

          def __do_touch_section p, sect

            _p_ = Magnetics_::Comparator_via_Section.call_by do |o|
              o.section = sect
            end

            sct = This_::Magnetics::TouchComparableElement_via_Element_and_Comparator_and_Elements.call_by do |o|
              o.element = sect
              o.comparator = _p_
              o.elements = @_all_elements_
            end

            # saying hello (you might want to emit something):

            if sct.found_existing
              sct.existing_element
            else
              sct.did_add || no
              sect
            end
          end

          def build_section_by_
            Magnetics_::Section_or_Subsection_via_DirectDefinition.call_by do |o|
              yield o  # hi.
            end
          end

          # -- read

          def dereference norm_sym
            DereferenceElement_via_NormalName_and_Collection_[ norm_sym, self ]
          end

          def lookup_softly norm_sym
            el = _lookup_softly_no_unwrap_ norm_sym
            el && el.value_as_result_of_dereference_or_lookup_softy_
          end

          def _lookup_softly_no_unwrap_ norm_sym
            LookupElementSoftlyNoUnwrap_via_NormalName_and_RelevantStream_[ norm_sym, _to_stream ]
          end

          def length
            _to_stream.flush_to_count
          end

          def first  # #testpoint (only)
            _to_stream.gets
          end

          def map & p  # #testpoint (only)
            _to_stream.join_into [], & p
          end

          def _to_stream
            Stream_[ @_all_elements_ ].reduce_by do |el|
              :_section_or_subsection_ == el._category_symbol_
            end
          end
          alias_method :to_stream_of_sections, :_to_stream
        end

        # ==
        # -

          def initialize
            @_mutex_for_whatever = nil
            @_child_elements_ = []
            yield self
            send remove_instance_variable :@_finish
            # can't freeze because assignments facade is made lazily
            # also, now you can mutate the subsection name any time.
          end

          undef_method :dup  # avoid accidentally calling this. see #here1

          # -- write these

          def SET_SUBSECTION_NAME s  # [cu]

            # this is to get some legacy stuff working .. might clean up
            # later. keep this in mind vis-a-vis [#008.G] and duping. as
            # it is written it should be dup-safe: the strings are frozen

            if s.include? NEWLINE_
              self._COVER_ME__no_newlines__in_subsection_names__
            end

            mutable_line = @_frozen_line.dup

            d = @__offset_of_name_start + @__width_of_section_name

            sl_w = @__width_of_subsection_leader
            if sl_w
              d += sl_w
              w = @__width_of_subsection_name
            else
              self._COVER_ME__re_sketched__
              mutable_line[ d, 0 ] = ' ""'
              d += 2  # yikes
              w = 0
            end

            use_s = s.dup
            Section_::Mutate_subsection_name_for_marshal[ use_s ]
            mutable_line[ d, w ] = use_s

            @_frozen_line = mutable_line.freeze
            @__width_of_subsection_name = use_s.length
            @subsection_string = s.freeze  # meh

            ACHIEVED_
          end

          def []= sym, x
            assign x, sym
            x
          end

          def assign x, sym, & p
            assign_by_ do |o|
              o.external_normal_name_symbol = sym
              o.mixed_value = x
              o.listener = p
            end
          end

          def assign_by_
            This_::Magnetics_::ApplyAssignment_via_Arguments.call_by do |o|
              yield o
              o.elements = @_child_elements_
            end
          end

          def build_assignment x, sym, & p  # [cu]

            This_::Magnetics_::Assignment_via_DirectDefinition.call_by do |o|
              o.external_normal_name_symbol = sym
              o.mixed_value = x
              o.listener = p  # if any
            end
          end

          def REPLACE_ALL_ELEMENTS el_a  # hax for [cu]

            @__assignments_facade = nil
            remove_instance_variable :@__assignments_facade

            old_a = @_child_elements_
            num_added = el_a.length - old_a.length
            old_a.clear ; old_a.push [ :_CHILD_ELEMENTS_ARRAY_WAS_REPLACED_br_ ] ; old_a.freeze
            @_child_elements_ = el_a
            num_added
          end

          # -- write during definition

          def init_for_parse_based_definition__
            remove_instance_variable :@_mutex_for_whatever
            @_parse_constructor = ParseContructor___.new
            @_finish = :__finish_via_parse_constructor
            NIL
          end

          def offset_of_name_start= x
            @_parse_constructor.offset_of_name_start = x
          end

          def width_of_section_name= x
            @_parse_constructor.width_of_section_name = x
          end

          def width_of_subsection_leader= x
            @_parse_constructor.width_of_subsection_leader = x
          end

          def width_of_subsection_name= x
            @_parse_constructor.width_of_subsection_name = x
          end

          def frozen_line= x
            @_parse_constructor.frozen_line = x
          end

          def __finish_via_parse_constructor

              offset_of_name_start, width_of_section_name,
              width_of_subsection_leader, width_of_subsection_name,
              frozen_line =  # (order must correspond to #here1)

            remove_instance_variable( :@_parse_constructor ).to_a

            if width_of_subsection_leader

              _d = offset_of_name_start + width_of_section_name + width_of_subsection_leader
              s = frozen_line[ _d, width_of_subsection_name ]
              Assignment_::Mutate_value_string_for_UNmarshal[ s ]
              frozen_subsect_s = s.freeze
            end

            _section_s = frozen_line[ offset_of_name_start, width_of_section_name ]

            _accept_sanitized_name_strings frozen_subsect_s, _section_s

            # ~ (
            @__offset_of_name_start = offset_of_name_start
            @__width_of_section_name = width_of_section_name
            @__width_of_subsection_leader = width_of_subsection_leader
            if width_of_subsection_leader
              @__width_of_subsection_name = width_of_subsection_name
            end
            # ~ )

            @_to_head_line = :__to_head_line_when_parsed
            @_frozen_line = frozen_line

            NIL
          end

          def accept_sanitized_name_strings_directly__ frozen_ss_s, sect_s

            remove_instance_variable :@_mutex_for_whatever
            _accept_sanitized_name_strings frozen_ss_s, sect_s
            @_to_head_line = :__to_head_line_when_defined_directly
            @_finish = :__finish_by_doing_nothing
            NIL
          end

          def __finish_by_doing_nothing
            NOTHING_
          end

          def _accept_sanitized_name_strings frozen_subsect_s, sect_s

            slug = sect_s.downcase

            @external_normal_name_symbol = slug.gsub( DASH_, UNDERSCORE_ ).intern
            @internal_normal_name_string = slug.freeze
            @__section_string = sect_s
            @subsection_string = frozen_subsect_s  # if any

            NIL
          end

          # -- write during parse

          def accept_assignment_ asmt
            @_child_elements_.push asmt
            ACHIEVED_  # for convenience
          end

          def accept_blank_line_or_comment_line_ frozen_line
            @_child_elements_.push BlankLine_or_CommentLine_.new frozen_line
            NIL
          end

          # -- read

          def assignments
            @__assignments_facade ||= This_::Models_::MutableAssignment::AssignmentsFacade.new @_child_elements_
          end

          def write_bytes_into y

            y << send( @_to_head_line )

            @_child_elements_.each do |el|
              el.write_bytes_into y
            end
            y
          end

          def to_line_stream_as_section__
            scn = nil ; p = nil ; main = -> do
              if scn.no_unparsed_exists
                p = EMPTY_P_ ; NOTHING_
              else
                # (our grammar allows us to assume all children are atomic)
                _el = scn.gets_one
                _el.to_line_as_atom_
              end
            end
            p = -> do
              line = send @_to_head_line
              scn = Scanner_[ @_child_elements_ ]
              p = main
              line
            end
            Common_.stream do
              p[]
            end
          end

          def __to_head_line_when_defined_directly
            s_s = @__section_string
            ss_s = @subsection_string
            if ss_s
              s = ss_s.dup
              Section_::Mutate_subsection_name_for_marshal[ s ]
              "[#{ s_s } \"#{ s }\"]#{ NEWLINE_ }"
            else
              "[#{ s_s }]#{ NEWLINE_ }"
            end
          end

          def __to_head_line_when_parsed
            @_frozen_line
          end

          def to_stream_of_all_elements
            Stream_[ @_child_elements_ ]
          end

          attr_reader(
            :external_normal_name_symbol,
            :internal_normal_name_string,
            :subsection_string,
          )

          def value_as_result_of_dereference_or_lookup_softy_
            self
          end

          def _category_symbol_
            :_section_or_subsection_
          end

          # ~ ( [cu]

          def is_section_or_subsection
            TRUE
          end
          def is_assignment
            FALSE
          end
          def is_blank_line_or_comment_line
            FALSE
          end

          # ~ )

          def _is_atom_
            FALSE
          end

          def _DUPLICATE_DEEPLY_  # #testpoint only. :#here1

            otr = self.class.allocate

            otr.instance_variable_set :@_child_elements_,
              @_child_elements_.map( & :_DUPLICATE_DEEPLY_ )

            # (or just dup..)
            %i(
              @external_normal_name_symbol
              @_frozen_line
              @internal_normal_name_string
              @__offset_of_name_start
              @__section_string
              @subsection_string
              @_to_head_line
              @__width_of_section_name
              @__width_of_subsection_leader
              @__width_of_subsection_name
            ).each do |ivar|
              otr.instance_variable_set ivar, instance_variable_get( ivar )
            end

            otr
          end

          def _FREEZE_AS_DOCUMENT_ELEMENT_  # #testpoint only
            @_child_elements_.each( & :_FREEZE_AS_DOCUMENT_ELEMENT_ )
            freeze
          end
        # -
        # ==

        ParseContructor___ = ::Struct.new(
          # (order must correspond to #here1)
          :offset_of_name_start, :width_of_section_name,
          :width_of_subsection_leader, :width_of_subsection_name,
          :frozen_line,
        )

        # ==
        # ==
      end
    end
  end
end
# #history-A: broke out of central "mutable" node (spiritually) during heavy refactor
