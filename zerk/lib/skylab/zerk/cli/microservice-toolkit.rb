module Skylab::Zerk

  module CLI::MicroserviceToolkit

    Autoloader_[ self ]

    class Listener_via < Common_::MagneticBySimpleModel

      def initialize
        @resource_by = nil
        super
      end

      attr_writer(
        :receive_did_err_by,
        :resource_by,
        :stderr,
      )

      def execute
        method :__receive_emission
      end

      def __receive_emission * chan, & ev

        sct = No_deps_zerk_[]::CLI_Express_via_Emission.call_by do |o|
          o.emission_proc_and_channel ev, chan
          o.resource_by = @resource_by
          o.stderr = @stderr
        end

        if sct
          if sct.has_resource
            sct.resource
          elsif sct.was_error
            @receive_did_err_by[]
            NIL
          end
        end
      end
    end

    # ==

    lazily :IsomorphicMethodsClient do
      Egads___[]
    end

    lazily :CLI_ArgumentScanner do
      No_deps_zerk_[]::CLI_ArgumentScanner
    end

    lazily :Scanners do  # you know.. for now..
      No_deps_zerk_[]
    end

    Egads___ = -> do
      Require_brazen_[]
      class IsomorphicMethodsClient < Brazen_::CLI
#====BEGIN

    # ~ definition phase

    class << self

      def option_parser & edit_p

        _cls = _touch_editable_action_class
        _cls.const_set :OPTION_PARSER_BLOCK___, edit_p
        NIL_
      end

      def description & lines_p

        _cls = _touch_editable_action_class
        _cls.const_set :DESCRIPTION_BLOCK_, lines_p
        NIL_
      end

      def __method_added m

        cls = _current_editable_action_class
        if cls
          remove_instance_variable :@_current_editable_action_class
          name = Common_::Name.via_variegated_symbol m
          _const = Common_::Name.via_variegated_symbol( m ).as_const
          __actions_module.const_set name.as_const, cls
          entry = Entry__.new name, self
        else
          entry = POSSIBLY_MINIMAL_ENTRY___
        end
        ( @__raw_entries ||= Common_::Box.new ).add m, entry
        NIL_
      end

      def _touch_editable_action_class
        @_current_editable_action_class ||= __make_editable_action_class
      end

      attr_reader :_current_editable_action_class

      def __make_editable_action_class

        ::Class.new Action_Adapter__
      end

      def __actions_module

        @___actions_module ||= __init_module_graph
      end

      def __init_module_graph

        _ = const_set :Modalities, ::Module.new
        _ = _.const_set :CLI, ::Module.new
        _.const_set :Actions, ::Module.new
      end
    end  # >>

    POSSIBLY_MINIMAL_ENTRY___ = class Possibly_Minimal_Entry____

      def _is_defined_
        false
      end
      self
    end.new

    def description_proc
      # for the top-level (branch) node description. for now, no DSL.
      NIL_
    end

    # ~ execution phase

    def initialize argv, i, o, e, pn_s_a

      super argv, i, o, e, pn_s_a, :back_kernel, User_Utility_as_Kernel___.new( self )
    end

    def send_invitation ev

      # (the normal top client cannot itself send invitations because
      #  these must happen from an action so thre is an action to invite
      #  towards)

      _receive_invitation ev, @adapter
    end

    class User_Utility_as_Kernel___

      attr_reader :_user_utility

      def initialize uu
        @_user_utility = uu
        @_user_utility_class = uu.class
      end

      def module
        @_user_utility_class
      end

      def fast_lookup
        NIL_  # maybe one day
      end

      def build_unordered_selection_stream & _
        @_user_utility_class.__cooked_unbounds.to_value_stream
      end
    end

    class << self

      def __cooked_unbounds

        if const_defined? :COOKED_UNBOUNDS__, false
          const_get :COOKED_UNBOUNDS__
        else
          const_set :COOKED_UNBOUNDS__, __cook_unbounds
        end
      end

      def __cook_unbounds

        h = {}
        public_instance_methods( false ).each do | m |
          h[ m ] = true
        end

        _bx = remove_instance_variable :@__raw_entries
        bx_ = Common_::Box.new

        amod = __actions_module

        _bx.each_pair do | k, ent |

          if ent._is_defined_

            bx_.add k, ent

          elsif h[ k ]

            # this is just a public method with no option parser.
            # the below hack lets the top invocation find our custom class

            nm = Common_::Name.via_variegated_symbol k

            amod.const_set nm.as_const, Action_Adapter__  # EEK

            bx_.add k, Entry__.new( nm, self )
          end
        end

        bx_
      end
    end  # >>

    class Entry__

      attr_reader(
        :name_function,
      )

      def initialize nm, uu
        @name_function = nm
        @_user_utility_class = uu
      end

      def silo_module
        @_user_utility_class  # or maybe not..
      end

      def adapter_class_for _moda
        NIL_
      end

      def _is_defined_
        true
      end

      def is_branch
        false
      end
    end

    class Action_Adapter__ < Brazen_::CLI::Action_Adapter_

      def initialize defined_entry, bound_kernel

        @bound = self
        @_nf = defined_entry.name_function
        @_custom_kernel = bound_kernel.kernel

        @_settable_by_environment_h = nil  # sux
      end

      def formal_properties
        @__fpx ||= __infer_formal_properties
      end

      def __infer_formal_properties

        o = Home_::Magnetics::FormalParameters_via_MethodParameters.new

        o.method = @_custom_kernel._user_utility.method( @_nf.as_variegated_symbol )

        @_egads = o

        o.execute
      end

      def description_proc
        ( @_desc_model ||= __build_description_model ).instance_description_proc
      end

      def __build_description_model
        Description___.of_instance self
      end

      def name
        @_nf
      end

      def is_visible
        true
      end

      def after_name_symbol
        NIL_  # ..
      end

      def init_properties
        NIL_  # none
      end

      def init_categorized_properties

        _ruby_params = @_custom_kernel._user_utility.method(
          @_nf.as_variegated_symbol
        ).parameters

        @_stx = Home_::Magnetics::FormalParameters_via_MethodParameters.new _ruby_params

        _opt_a = [
          Brazen_::CLI_Support.standard_action_property_box_.fetch( :help ) ]

        if @_stx.argument_term_count.nonzero?
          _arg_a = @_stx.to_a
        end

        @categorized_properties =
          Brazen_::CLI_Support::Categorized_Properties.via_args_opts_envs(
            _arg_a, NIL_, _opt_a )

        NIL_
      end

      def populated_option_parser_via opt_a, op

        # (the fact that this works is fragile. see caller)

        cls = self.class
        if cls.const_defined? :OPTION_PARSER_BLOCK___
          p = cls.const_get :OPTION_PARSER_BLOCK___
        end

        if p
          @_custom_kernel._user_utility.instance_exec op, & p
        end

        super  # will add the '-h' option
      end

      def prepare_to_parse_parameters

        # unlike parent we do *not* need to use @mutable_backbound_iambic
        # so (for sanity) we do not init it here.

        @seen = Common_::Box.new  # but we use this (see next method)

        NIL_
      end

      def mutate_backbound_iambic_ prp

        # unlike parent we do not write to @mutable_backbound_iambic so
        # we do a simplified version of things here

        touch_argument_metadata prp.name_symbol

        NIL_
      end

      def write_any_auxiliary_syntax_strings_into_ y

        # unlike parent which checks for the existence of any property
        # called 'help', we always support this action-like option.

        _ho = Brazen_::CLI_Support.standard_action_property_box_.fetch :help
        y << auxiliary_syntax_string_for_help_option_( _ho )
      end

      def bound_call_from_parse_arguments

        # the last step: fail because args length or succeed w/ the bound call

        argv = @resources.argv

        bc = @_stx.validate_against_args argv do |o|

          o.on__missing__ do |miss_ev|

            Brazen_::CLI::When_[]::Missing_Arguments_Fancy.new miss_ev, expression_
          end

          o.on__extra__ do |xtra_ev|

            Brazen_::CLI::When_[]::Extra_Arguments.new xtra_ev.x, expression_
          end

          o.on__success__ do

            NIL_  # invert the usual T/F for succeed/fail
          end
        end

        if bc
          bc
        else

          Common_::BoundCall[
            argv,
            @_custom_kernel._user_utility,
            @_nf.as_variegated_symbol
          ]
        end
      end
    end

    # ==

    # ==

    class Description___  # ancient, moved here from [#ze-054.2] at #tombstone-A

      class << self

        def of_instance inst

          if inst.class.const_defined? :DESCRIPTION_BLOCK_
            new inst
          else
            THE_EMPTY_DESCRIPTION___
          end
        end
        private :new
      end  # >>

      def initialize inst
        @__description_proc = inst.class.const_get :DESCRIPTION_BLOCK_
      end

      def instance_description_proc
        @__description_proc  # (hi.)
      end
    end

    module THE_EMPTY_DESCRIPTION___ ; class << self
      def instance_description_proc
        NOTHING_
      end
    end ; end

    class << self
      alias_method :method_added, :__method_added
      undef_method :__method_added
    end

    # ==

    # ==

      end

      NIL
    end  # egads
#===
    Here_ = self
    SUCCESS_EXITSTATUS = SUCCESS_EXITSTATUS  # part of subject's public API
  end
end
# #history: moved to [ze] from [br]
# #tombstone-A: model node used to be in remote node
