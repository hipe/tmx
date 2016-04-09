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

      Compound_Frame__ = ::Class.new self

      class Root < Compound_Frame__

        def initialize cli, acs
          @CLI = cli
          @next_frame_ = nil
          super acs
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

        def get_program_name_string__
          build_program_name_string_array_.join SPACE_
        end

        def build_program_name_string_array_
          @CLI.build_expressible_program_name_string_array__
        end

        attr_reader(
          :CLI,  # #spot-1
        )

        def name
          NOTHING_
        end

        def is_root
          true
        end
      end

      NonRoot_Methods__ = ::Module.new

      class NonRootCompound___ < Compound_Frame__

        include NonRoot_Methods__

        def initialize former_top, qk

          @_association = qk.association
          @next_frame_ = former_top
          super qk.value_x
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

        def initialize former_top, fo

          @formal_operation_ = fo
          @next_frame_ = former_top
          @_sns = nil
        end

        def operation_syntax_
          @___os ||= Here_::Operation_Syntax___.new self
        end

        def syntax__  # assert-esque is already determined
          @___os
        end

        def to_defined_formal_parameter_stream__
          @formal_operation_.to_defined_formal_parameter_stream
        end

        def has_stated_parameters__
          @formal_operation_.has_defined_formal_parameters
        end

        # --

        def description_proc_
          @formal_operation_.description_proc
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
          s_a.push subprogram_name_slug_
          s_a
        end

        def subprogram_name_slug_
          name.as_slug
        end
      end

      # --

      class Compound_Frame__

        def initialize acs
          @ACS = acs
          @_did_big_index = false
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

        def lookup_formal_node__ token, set_sym, & oes_p
          Lookup__.new( token, set_sym, self, & oes_p ).execute
        end

        ATTACH_FOR___ = {
          association: :__attach_frame_via_association,
          formal_operation: :attach_operation_frame_via_formal_operation_,
        }

        def __attach_frame_via_association asc
          _m = ATTACH_ASC_FOR___.fetch asc.model_classifications.category_symbol
          send _m, asc
        end

        ATTACH_ASC_FOR___ = {
          compound: :attach_compound_frame_via_association_,
        }

        def attach_operation_frame_via_formal_operation_ fo
          Operation___.new self, fo
        end

        def attach_compound_frame_via_association_ asc
          _qk = qualified_knownness_of_touched_via_association_ asc
          NonRootCompound___.new self, _qk
        end

        def qualified_knownness_of_touched_via_association_ asc
          ACS_::Interpretation::Touch[ asc, _reader ]
        end

        def streamer_for_navigational_node_tickets_  # [#030] defines "navigational"

          method :to_navigational_node_ticket_stream_
        end

        def to_navigational_node_ticket_stream_

          @_did_big_index || _do_big_index

          Callback_::Stream.via_nonsparse_array @__navigational_NTs
        end

        def to_referenceable_node_ticket_stream__

          @_did_big_index || _do_big_index

          Callback_::Stream.via_nonsparse_array @__referenceable_NTs
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

          st = _reader.to_node_ticket_streamer.execute
          begin
            nt = st.gets
            nt or break
            which.fetch( nt.node_ticket_category ).call
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

        def build_formal_operation_via_node_ticket_ nt  # should be 2x, is 1 for nau

          _fo_p = _fo_proc_via_name_symbol nt.name_symbol

          _formal_operation_via_formal_operation_proc _fo_p, nt.name
        end

        def _formal_operation_via_formal_operation_proc fo_p, nf=nil

          a = _build_frame_stack_from_bottom
          if nf
            a.push nf
          else
            a.push NIL_  # use [#as-030] to discover name
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

        did = false
        define_method :___build_reader do
          did or did = true && Require_ACS_[]
          ACS_::ReaderWriter.for_componentesque @ACS
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

          st = __to_frame_stream_from_bottom

          s = st.gets.get_program_name_string__

          begin
            fr = st.gets
            fr or break
            s << SPACE_
            s << fr.subprogram_name_slug_
            redo
          end while nil

          s
        end

        def expressible_program_name_string_array_
          @___pnsa ||= build_program_name_string_array_  # caching may not be useful
        end

        # --

        def __to_frame_stream_from_bottom

          _a = _build_frame_stack_from_bottom
          Callback_::Stream.via_nonsparse_array _a
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

          Callback_.stream do
            p[]
          end
        end

        # --

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

          # (this wording gets pretty personal, exhibiting perhaps a design
          # issue with the scope of this node v.s its client. might push up)

          fn = @_formal_node
          had = ' (was primitivesque).'
          @_oes_p.call :error, :expression, :result_node_is_wrong_shape do |y|
            y << "#{ nm fn.name } is not accessed with that syntax #{ had }"
          end
          UNABLE_
        end

        # -- fuzz

        def __resolve_any_formal_node_fuzzily  # (must init @_formal_node )

          # try to match the token fuzzily (but unambiguously) to one of
          # the nodes directly under this frame. if none found, emit a
          # "did you mean (..)"-style emission. result is the found nerp
          # or false.

          o = Begin_fuzzy_retrieve_[ & @_oes_p ]

          _m = APPROPRIATE_STREAMER___.fetch @set_sym

          o.stream_builder = @services.send _m

          o.name_map = -> qk do
            qk.name.as_slug
          end

          o.set_qualified_knownness_value_and_name @token, Node_Name___[]

          svcs = @services
          o.suffixed_contextualization_message_proc = -> y, _o do
            svcs._suffixed_context_into_under y, self
          end

          nt = o.execute
          if nt
            send INIT_FORMAL_NODE___.fetch( nt.node_ticket_category ), nt
          else
            @_formal_node = nt
            nt
          end
        end

        APPROPRIATE_STREAMER___ = {
          navigational: :streamer_for_navigational_node_tickets_,
        }

        INIT_FORMAL_NODE___ = {
          association: :__resolve_formal_node_for_association,
          operation: :__resolve_formal_node_for_operation,
        }

        Node_Name___ = Lazy_.call do
          Callback_::Name.via_human 'node name'
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
