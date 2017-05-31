module Skylab::Zerk

  class NonInteractiveCLI

    class Stack_Frame__  # code-notes in [#024]

      # properieter: only the core niCLI node, which builds only a Root.

      # for implementing the linked list as described at "why linked list",
      # 3 classes for the 3 kinds of stack frames: root, non-root compound,
      # and formal operation. a complete "selection stack" will always have
      # the form:
      #
      #     ROOT [ NON-ROOT-COMPOUND [..]] FORMAL-OPERATION

      # this sub-sub-system is the owner of behavior near parsing and adding
      # frames to the stack, so that the main parser and the help subsystem
      # can both share its facilities with the same interface and behavior.

      CompoundFrame__ = ::Class.new self

      class Root < CompoundFrame__

        def initialize node_map, cli, acs
          @CLI = cli
          @next_frame_ = nil
          @_reader_builder_for_this_frame = cli.produce_reader_for_root_by
          super acs, node_map
        end

        def description_proc_
          _any_description_proc_thru_ACS_class_method
        end

        def _suffixed_context_into_under y, _expag
          y
        end

        def _suffixed_context_into_string_under s, _expag
          s
        end

        def get_program_name_string
          build_program_name_string_array_.join SPACE_
        end

        def build_program_name_string_array_
          @CLI.build_program_name_string_array_as_root_stack_frame__
        end

        attr_reader(
          :CLI,  # #spot-1
        )

        def name
          NOTHING_
        end

        def root_frame
          self
        end

        def is_root
          true
        end
      end

      NonRoot_Methods__ = ::Module.new

      class NonRootCompound___ < CompoundFrame__

        include NonRoot_Methods__

        def initialize former_top, qk, node_map

          @_association = qk.association
          @next_frame_ = former_top
          @_reader_builder_for_this_frame = nil  # not yet available
          super qk.value, node_map
        end

        def description_proc_
          p = @_association.description_proc
          if p
            p
          else
            _any_description_proc_thru_ACS_class_method
          end
        end

        def _suffixed_context_into_under y, expag
          s = "in"
          _suffixed_context_into_string_under s, expag
          y << s
        end

        def _suffixed_context_into_string_under s, expag
          @next_frame_._suffixed_context_into_string_under s, expag
          s << SPACE_
          nf = name
          expag.calculate do
            s << nm( nf )
          end
          s
        end

        def name
          @_association.name
        end
      end

      class Operation___ < self

        include NonRoot_Methods__

        def initialize former_top, fo, map_x

          @formal_operation_ = fo
          @next_frame_ = former_top
          @_custom_op_proc = nil
          @_to_defined_formal_parameter_stream = :_to_defined_formal_parameter_stream_normally
          @_sns = nil

          if map_x
            __process_map map_x
          end
        end

        # -- exactly "node maps" (#mode-tweaking) in [#003]

        def __process_map map_proc
          oc = Here_::OperationCustomization___.new self
          if map_proc.arity.zero?
            _node_map = map_proc.call
            oc.map_these_formal_parameters _node_map
          else
            map_proc[ oc ]
          end
          NIL
        end

        # ~ facilities for processing the above

        def operation_customization_says_use_this_op_proc__ p
          @has_custom_option_parser__ = true
          @_custom_op_proc = p ; nil
        end

        def operation_customization_says_parameters_being_mutable_box_
          @___did ||= __convert_parameters_to_mutable_box
          @_mutable_FP_box
        end

        def __convert_parameters_to_mutable_box

          _st = _to_defined_formal_parameter_stream_normally
          @_mutable_FP_box = _st.flush_to_box_keyed_to_method :name_symbol
          @_to_defined_formal_parameter_stream =
            :__to_defined_formal_parameter_stream_when_mutable_box
          ACHIEVED_
        end

        def __to_defined_formal_parameter_stream_when_mutable_box
          @_mutable_FP_box.to_value_stream
        end

        attr_reader(
          :has_custom_option_parser__,
        )

        # --

        def remove_positional_argument sym  # [pe]
          operation_syntax_.remove_positional_argument__ sym
        end

        def operation_syntax_
          @___os ||= Here_::Operation_Syntax___.new( @_custom_op_proc,  self )
        end

        def syntax__  # assert-esque is already determined
          @___os
        end

        def to_defined_formal_parameter_stream__
          send @_to_defined_formal_parameter_stream
        end

        def formal_parameter sym
          @formal_operation_.formal_parameter sym
        end

        def _to_defined_formal_parameter_stream_normally

          # when there's singplur counterparts, don't represent both of them..

          @formal_operation_.to_defined_formal_parameter_stream
        end

        def __to_defined_formal_parameter_stream_customly
          Common_::Stream.via_nonsparse_array @_custom_parameters
        end

        def has_stated_parameters__
          @formal_operation_.has_defined_formal_parameters
        end

        # --

        def description_proc_

          p = @formal_operation_.description_proc
          if p
            p
          else
            @formal_operation_.description_proc_thru_implementation
          end
        end

        def name
          @formal_operation_.name
        end

        attr_reader(
          :formal_operation_,  # 2x
        )

        def _3_normal_shape_category_
          :operation
        end
      end

      module NonRoot_Methods__

        def build_program_name_string_array_

          s_a = @next_frame_.expressible_program_name_string_array_
          s_a.push subprogram_name_slug
          s_a
        end

        def subprogram_name_slug
          name.as_slug
        end

        def root_frame
          @next_frame_.root_frame
        end
      end

      # --

      class CompoundFrame__

        def initialize acs, node_map
          @ACS = acs
          @_did_big_index = false
          @_node_map = node_map
          @_sns = nil
        end

        # --

        def _any_description_proc_thru_ACS_class_method

          if @ACS.respond_to? :describe_into_under
            acs = @ACS
            -> y do
              acs.describe_into_under y, self
            end
          end
        end

        # --

        def compound_option_parser__
          @___COP ||= ___build_compound_option_parser
        end

        def ___build_compound_option_parser

          # this serves 2-ish purposes:
          #
          # 1) be something trueish for the section renderer #over-here so we
          #    can have 2-column layout when rendering help screens for
          #    compound nodes. provide the 2 metrics needed for this: `summary_indent` & `summary_width`.
          #
          # 2) maybe actually parse something..

          op = Home_.lib_.stdlib_option_parser.new

          op.on '-h', '--help [<action>]',
              'this screen (or help for that action)' do |s|

            self._K_readme  # send to a bespoke, mutable callback here :(
          end

          op
        end

        # --

        def lookup_and_attach_frame__ token, set_sym, & oes_p
          fn = Lookup__.new( token, set_sym, self, & oes_p ).execute
          if fn
            send ATTACH_FOR___.fetch( fn.formal_node_category ), fn
          else
            fn
          end
        end

        ATTACH_FOR___ = {
          association: :__attach_frame_via_association,
          formal_operation: :attach_operation_frame_via_formal_operation_,
        }

        def lookup_formal_node__ token, set_sym, & oes_p
          Lookup__.new( token, set_sym, self, & oes_p ).execute
        end

        def __attach_frame_via_association asc
          _m = ATTACH_ASC_FOR___.fetch asc.model_classifications.category_symbol
          send _m, asc
        end

        ATTACH_ASC_FOR___ = {
          compound: :attach_compound_frame_via_association_,
        }

        def attach_operation_frame_via_formal_operation_ fo

          # will move
          p = @_node_map
          if p
            _node_map = p[ fo.name_symbol ]
          end

          Operation___.new self, fo, _node_map
        end

        def attach_compound_frame_via_association_ asc

          _qk = qualified_knownness_of_touched_via_association_ asc

          p = @_node_map
          if p
            self._COVER_ME_never_carried_a_node_map_deeper_than_one_level
            _node_map = p[ asc.name_symbol ]
          end

          NonRootCompound___.new self, _qk, _node_map
        end

        def qualified_knownness_of_touched_via_association_ asc
          Arc_::Magnetics::TouchComponent_via_Association_and_OperatorBranch[ asc, _reader ]
        end

        def streamer_for_navigational_node_references_  # [#030] defines "navigational"

          method :to_navigational_node_reference_stream_
        end

        def to_navigational_node_reference_stream_

          @_did_big_index || _do_big_index

          Common_::Stream.via_nonsparse_array @__navigational_NTs
        end

        def to_referenceable_node_reference_stream__

          @_did_big_index || _do_big_index

          Common_::Stream.via_nonsparse_array @__referenceable_NTs
        end

        def _do_big_index  # we avoid this #"heavy lift" when possible..

          @_did_big_index = ACHIEVED_

          navs = nil
          refs = nil

          nt = nil  # [#030]

          which2 = {
            compound: -> do
              ( navs ||= [] ).push nt
            end,
            entitesque: -> do
              ( refs ||= [] ).push nt
            end,
            primitivesque: -> do
              ( refs ||= [] ).push nt
            end,
          }

          which = {
            operation: -> do
              ( navs ||= [] ).push nt
              ( refs ||= [] ).push nt
            end,
            association: -> do
              _ = nt.association.model_classifications.category_symbol
              which2.fetch( _ ).call
            end,
          }

          st = _reader.to_node_reference_streamer.execute
          begin
            nt = st.gets
            nt or break
            which.fetch( nt.node_reference_category ).call
            redo
          end while nil

          @__navigational_NTs = navs || EMPTY_A_
          @__referenceable_NTs = refs || EMPTY_A_
          NIL_
        end

        # == simple reader interface

        # ~ association - value / formal node

        def for_invocation_read_atomesque_value_ asc
          _reader.read_value asc
        end

        def __association_via_name_symbol sym
          _reader.read_association sym
        end

        # ~ formal operation - formal node / proc

        def build_formal_operation_via_node_reference_ nt  # should be 2x, is 1 for nau

          _fo_p = _fo_proc_via_name_symbol nt.name_symbol

          _formal_operation_via_formal_operation_proc _fo_p, nt.name
        end

        def _formal_operation_via_formal_operation_proc fo_p, nf=nil

          a = _build_frame_stack_from_bottom
          if nf
            a.push nf
          else
            a.push NOTHING_  # use [#as-030] to discover name
          end
          fo_p[ a ]  # can be nil but ignore this fact for now..
        end

        def _fo_proc_via_name_symbol sym
          _reader.read_formal_operation sym
        end

        # ==

        def _reader
          @_reader ||= ___build_reader
        end

        alias_method :reader_writer_, :_reader  # track who needs it

        yes = true
        reader_builder = nil

        define_method :___build_reader do

          if yes
            yes = false
            Require_ACS_[]
            reader_builder = ACS_::Magnetics::OperatorBranch_via_ACS.method :for_componentesque
          end

          p = @_reader_builder_for_this_frame
          if p
            p[ @ACS, reader_builder ]
          else
            reader_builder[ @ACS ]
          end
        end

        attr_reader(
          :ACS,  # [ac] formal op reads it on construction
        )

        def _3_normal_shape_category_
          :compound
        end
      end

      # -

        def subprogram_name_string_  # (at writing, only for help (2x))
          @_sns ||= _assemble_subprogram_name_string
        end

        def _assemble_subprogram_name_string

          st = to_frame_stream_from_bottom

          s = st.gets.get_program_name_string

          begin
            fr = st.gets
            fr or break
            s << SPACE_
            s << fr.subprogram_name_slug
            redo
          end while nil

          s
        end

        def expressible_program_name_string_array_
          @___pnsa ||= build_program_name_string_array_  # caching may not be useful
        end

        # --

        def to_frame_stream_from_bottom  # [my]

          _a = _build_frame_stack_from_bottom
          Common_::Stream.via_nonsparse_array _a
        end

        def _build_frame_stack_from_bottom
          to_frame_stream_from_top_.to_a.reverse  # hm.. [#bm-011]
        end

        def to_frame_stream_from_top_

          cur = self
          p = -> do
            nxt = cur.next_frame_
            if nxt
              x = cur
              cur = nxt
              x
            else
              p = EMPTY_P_
              cur
            end
          end

          Common_.stream do
            p[]
          end
        end

        # --

        def all_purpose_cache  # crutch for [my]
          @___APC ||= {}
        end

        attr_reader(
          :next_frame_,
        )

        def is_root
          false
        end
      # -

      # ==

      class Lookup__

        # attempt to resolve a [#030] formal node through a variety of means
        # (association, operation, fuzzily) for a variety of target sets
        # (navigational, ..):
        #
        #   • IFF any node is not found/ambiguous,
        #     * side-effects an emission
        #     * result is false
        #   • otherwise (and found):
        #     * side-effects any auto-vivification of any compound nodes.
        #     * IFF actual shape matches target set
        #       + result is the association or formal operation
        #     * otherwise (and shape didn't match..)
        #       + try to be helpful with an emission
        #       + result is false

        def initialize token, set_sym, services, & oes_p
          @services = services
          @set_sym = set_sym
          @token = token
          @_oes_p = oes_p
        end

        def execute
          did = __resolve_any_formal_node_directly
          did ||= __resolve_any_formal_node_fuzzily
          if did
            send :"__#{ @set_sym }__and__#{ Formal_node_3_category_[ @_formal_node ] }__"
          else
            did
          end
        end

        # --

        # (turn this into branch hashes when it gets ridiculous)

        def __navigational__and__formal_operation__
          @_formal_node
        end

        def __navigational__and__compound__
          @_formal_node
        end

        def __navigational__and__primitivesque__  # t4

          _cant_go_this_way 'a primitivesque'
        end

        def __navigational__and__entitesque__

          _cant_go_this_way 'an entitesque'
        end

        def _cant_go_this_way which_s

          # (this wording gets pretty personal, exhibiting perhaps a design
          # issue with the scope of this node v.s its client. might push up)

          fn = @_formal_node
          @_oes_p.call :error, :expression, :result_node_is_wrong_shape do |y|
            y << "#{ nm fn.name } (#{ which_s }) #{
              }is not accessed with that syntax."
          end
          UNABLE_
        end

        # -- fuzz

        def __resolve_any_formal_node_fuzzily  # (must init @_formal_node )

          # try to match the token fuzzily (but unambiguously) to one of
          # the nodes directly under this frame. if none found, emit a
          # "did you mean (..)"-style emission. result is the found nerp
          # or false.

          nt = Home_.lib_.brazen::Magnetics::Item_via_OperatorBranch::FYZZY.call_by do |o|

            _m = APPROPRIATE_STREAMER___.fetch @set_sym

            o.item_stream_proc = @services.send _m

            o.string_via_item_by do |node_ref|
              node_ref.name.as_slug
            end

            o.set_qualified_knownness_value_and_name @token, Node_Name___[]

            svcs = @services
            o.suffixed_contextualization_message_proc = -> y, _o do
              svcs._suffixed_context_into_under y, self
            end

            o.levenshtein_number = LEVENSHTEIN_NUMBER_  # see

            o.listener = @_oes_p
          end

          if nt
            send INIT_FORMAL_NODE___.fetch( nt.node_reference_category ), nt
          else
            @_formal_node = nt
            nt
          end
        end

        APPROPRIATE_STREAMER___ = {
          navigational: :streamer_for_navigational_node_references_,
        }

        INIT_FORMAL_NODE___ = {
          association: :__resolve_formal_node_for_association,
          operation: :__resolve_formal_node_for_operation,
        }

        Node_Name___ = Lazy_.call do
          Common_::Name.via_human 'node name'
        end

        def __resolve_formal_node_for_operation nt

          _fo_p = nt.proc_to_build_formal_operation

          @_formal_node = @services._formal_operation_via_formal_operation_proc _fo_p

          ACHIEVED_
        end

        def __resolve_formal_node_for_association nt

          @_formal_node = nt.association

          ACHIEVED_
        end

        # -- direct lookups

        def __resolve_any_formal_node_directly

          @_name_symbol = @token.gsub( DASH_, UNDERSCORE_ ).intern

          _did = __lookup_as_association
          _did || __lookup_as_operation
        end

        def __lookup_as_association

          fn = @services.__association_via_name_symbol @_name_symbol
          if fn
            @_formal_node = fn
            ACHIEVED_
          else
            fn
          end
        end

        def __lookup_as_operation
          fo_p = @services._fo_proc_via_name_symbol @_name_symbol
          if fo_p
            @_formal_node = @services._formal_operation_via_formal_operation_proc fo_p
            ACHIEVED_
          else
            fo_p
          end
        end
      end
      # ==
    end
  end
end
