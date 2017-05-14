module Skylab::TanMan

  module Model_

    # ==

    # parts of the below may or may not redund with the #[#ze-002.1] as we
    # drive the dust towards settling along that strain.
    #
    # however, [tm] has been historically and continues to be the
    # application that frontiers modeling to the limit of its design, and
    # as such it would follow that things are ornate here.

    # ==

    Bound_call_via_action_with_definition = -> act do

      # (started as copy-paste of [sn]. diverged significantly for `properties`)

      # (now this has become a specialized variant of [#br-024], and is
      # used as an example of a customized action grammar.)

      # ~ hand-written map reduce:

      _first_grammar = Here_.__action_grammar_

      token_scn = Scanner_[ act.definition ]

      current_all_qual_item_st = _first_grammar.stream_via_scanner token_scn

      p = nil
      expand_using_this = nil
      see_association = nil

      main = -> do

        begin

          qual_item = current_all_qual_item_st.gets
          qual_item || break

          case qual_item.injection_identifier

          when :_parameter_TM_
            x = qual_item.item
            see_association[ x ]
            break

          when :_DOC_parameter_TM_  # hi. (keep this identical to above)
            x = qual_item.item
            see_association[ x ]
            break

          when :_branch_desc_TM_
            redo

          when :_several_props_TM_
            expand_using_this[ qual_item.item ]
            x = p[] ; break

          when :_document_specific_parameter_grammar_TM_

            _g = Home_::DocumentMagnetics_::CommonAssociations::This_one_grammar[]
            current_all_qual_item_st = _g.stream_via_scanner token_scn
            token_scn.advance_one
            redo

          else
            no
          end
        end while above
        x
      end

      expand_using_this = -> x do

        st = if x.respond_to? :gets
          x
        else
          st = Stream_[ x ]
        end

        p = -> do
          asc = st.gets
          if asc
            see_association[ asc ]
            asc
          else
            p = main
            p[]
          end
        end
      end

      see_association = -> asc1 do

        # (the first time you receive an association, see if the action
        # is subscribed to receiving the associations; etc.)

        if act.instance_variable_defined? :@_associations_
          # (as described at [#031])
          # (make this a hook-in method when desired and move this #here2)
          h = act.instance_variable_get :@_associations_
          see_association = -> asc do
            h[ asc.name_symbol ] = asc ; nil
          end
        else
          see_association = MONADIC_EMPTINESS_
        end
        see_association[ asc1 ]
      end

      p = main

      _asc_st = Common_.stream do
        p[]
      end

      # ~

      ok = MTk_::Normalization.call_by do |o|

        o.association_stream_newschool = _asc_st

        o.entity_nouveau = act

        o.will_nilify  # because of #here1
      end

      if ok
        Common_::BoundCall.by( & act.method( :execute ) )
      else
        NIL_AS_FAILURE_
      end
    end

    # ==

    define_singleton_method :__action_grammar_, ( Lazy_.call do

      # all actions will leverage our custom association subclass, even
      # those that don't need to.
      #
      # however, in order to isolate the implemetation of our custom
      # associations to their own subdomain, that happens near #spot1.1

      _param_gi = my_custom_grammatical_injection_without_custom_meta_associations_

      Home_.lib_.parse_lib::IambicGrammar.define do |o|

        o.add_grammatical_injection :_branch_desc_TM_, BRANCH_DESCRIPTION___

        o.add_grammatical_injection :_parameter_TM_, _param_gi

        o.add_grammatical_injection :_several_props_TM_, SEVERAL_PROPS___

        o.add_grammatical_injection :_document_specific_parameter_grammar_TM_, THIS_ONE_KEYWORD___
      end
    end )

    module THIS_ONE_KEYWORD___ ; class << self

      def is_keyword k
        :use_this_one_custom_attribute_grammar == k
      end

      def gets_one_item_via_scanner _
        :__anything_trueish__
      end
    end ; end

    module BRANCH_DESCRIPTION___ ; class << self

      def is_keyword k
        :branch_description == k
      end

      def gets_one_item_via_scanner scn
        scn.advance_one ; scn.gets_one
      end
    end ; end

    module SEVERAL_PROPS___ ; class << self

      def is_keyword k
        :properties == k
      end

      def gets_one_item_via_scanner scn
        scn.advance_one ; scn.gets_one
      end
    end ; end

    def self.my_custom_grammatical_injection_without_custom_meta_associations_

      _orig = __common_association_grammatical_injection
      _orig.redefine do |o|
        o.item_class = __my_custom_association_class
        # the two models (prefix, postfix) are left as-is here.
      end
    end

    define_singleton_method :__my_custom_association_class, ( Lazy_.call do

      class ApplicationSpecificCustomizedAssociation____ < _common_association_class

        def redefine  # experiment
          otr = dup
          yield otr
          otr.freeze
        end

        def be_optional
          @is_required = false ; nil
        end

        attr_accessor(
          :_throughput_characteristics_,
        )

        def expresses_direction
          TRUE  # for now..
        end

        self
      end
    end )

    def self.__common_association_grammatical_injection
      _common_association_class.grammatical_injection
    end

    def self._common_association_class
      Fields_lib_[]::CommonAssociation::EntityKillerParameter
    end

    # ==

    module CommonActionMethods

      def init_action_ invo
        invo.HELLO_INVOCATION  # #todo
        @_microservice_invocation_ = invo
      end

      # (:#here2)

      # --

      def with_mutable_digraph_

        _is_dry = remove_instance_variable :@dry_run
        @dry_run = _is_dry  # meh

        _mutable_or_immutable_digraph_session_MO do |o|

          o.be_read_write_not_read_only_

          o.session_by do |dc|
            @_mutable_digraph_ = dc
            x = yield
            remove_instance_variable :@_mutable_digraph_
            x
          end

          o.is_dry_run = _is_dry
        end
      end

      def with_immutable_digraph_

        _mutable_or_immutable_digraph_session_MO do |o|

          o.be_read_only_not_read_write_

          o.session_by do |dc|
            @_immutable_digraph_ = dc
            x = yield
            remove_instance_variable :@_immutable_digraph_
            x
          end
        end
      end

      def _mutable_or_immutable_digraph_session_MO

        # really hacky: at writing some actions are "fully configurable" in
        # how they can take arguments to represent/indicate a digraph; and
        # others use solely the workspace for this. because FOR NOW we
        # already have the workspace session thing here, we want to use that
        # if we've got it (will likely all change), otherwise ..

        if instance_variable_defined? :@_associations_
          _bx = to_box_
          _digraph_session_MO do |o|
            yield o
            o.qualified_knownness_box = _bx
          end
        else
          with_immutable_workspace_ do
            _digraph_session_MO do |o|
              yield o
              o.immutable_workspace = @_immutable_workspace_
            end
          end
        end
      end

      def _digraph_session_MO

        Home_::Models_::DotFile::DigraphSession_via_THESE.call_by do |o|
          yield o
          o.microservice_invocation = @_microservice_invocation_
          o.listener = _listener_
        end
      end

      # --

      def with_mutable_workspace_

        # assume these variables are ours for consumption (:#here1):

        # here's a nasty trick: we don't want to procede unless
        # this is set, but leave it set for others to read:

        dry = remove_instance_variable :@dry_run
        @dry_run = dry

        _ = _with_mutable_or_immutable_workspace_MO do |o|

          o.do_this_with_mutable_workspace do |ws|
            @_mutable_workspace_ = ws
            x = yield
            remove_instance_variable :@_mutable_workspace_
            x
          end

          o.is_dry_run = dry
        end

        _ || NIL_AS_FAILURE_
      end

      def with_immutable_workspace_

        _with_mutable_or_immutable_workspace_MO do |o|

          o.do_this_with_immutable_workspace do |ws|
            @_immutable_workspace_ = ws
            x = yield
            remove_instance_variable :@_immutable_workspace_
            x
          end
        end
      end

      def _with_mutable_or_immutable_workspace_MO

        _mnd = remove_instance_variable :@max_num_dirs_to_look
        _wsp = remove_instance_variable :@workspace_path
        _cfn = remove_instance_variable :@config_filename

        _mag = Home_.lib_.brazen_NOUVEAU::Models::Workspace::Magnetics::Workspace_via_Request
        _ = _mag.call_by do |o|

          yield o

          o.workspace_class_by do
            Home_::Models_::Workspace
          end

          o.init_workspace_by do |ws|
            ws.HELLO_MY_OWN_WORKSPACE
          end

          o.config_filename = _cfn
          o.max_num_dirs_to_look = _mnd
          o.workspace_path = _wsp
          o.filesystem = _invocation_resources_.filesystem
          o.listener = _listener_
        end

        _ || NIL_AS_FAILURE_
      end

      define_method :_store_, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      def _simplified_write_ k, x
        instance_variable_set :"@#{ k }", x
        NIL
      end

      def to_box_  # #experiment. replaces something in [br]
        bx = Common_::Box.new
        @_associations_.each_value do |asc|
          k = asc.name_symbol
          ivar = :"@#{ k }"
          # -
            x = instance_variable_get ivar
          # -
          _qkn = Common_::QualifiedKnownness.via_value_and_association x, asc
          bx.add k, _qkn
        end
        bx
      end

      def _simplified_read_ k
        ivar = :"@#{ k }"
        if instance_variable_defined? ivar
          instance_variable_get ivar
        end
      end

      def _listener_
        _invocation_resources_.listener
      end

      def _argument_scanner_
        _invocation_resources_.argument_scanner
      end

      def _invocation_resources_
        @_microservice_invocation_.invocation_resources
      end
    end

    # ==

    Here_ = self
    MONADIC_EMPTINESS_ = -> _ { NOTHING_ }
  end  # `Model_`
end
# #tombstone-E.2: "stubbing", "model" base class, "action" base class
# #tombstone-E.1: compartmentalize workspace node
# #tombstone-D: we once had `take` defined as a stream method
# #tombstone: remote add, list, rm (ancient, deprecated); check, which
# :+#tombstone: this used to be bottom properties frame
# :+#tombstone: remote model (3 lines)
