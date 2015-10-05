module Skylab::Brazen

  class CLI::Isomorphic_Methods_Client < CLI

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

      def method_added m

        cls = _current_editable_action_class
        if cls
          remove_instance_variable :@_current_editable_action_class
          name = Callback_::Name.via_variegated_symbol m
          _const = Callback_::Name.via_variegated_symbol( m ).as_const
          __actions_module.const_set name.as_const, cls
          entry = Entry__.new name, self
        else
          entry = POSSIBLY_MINIMAL_ENTRY___
        end
        ( @__raw_entries ||= Callback_::Box.new ).add m, entry
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

    # ~ execution phase

    def initialize i, o, e, pn_s_a

      super i, o, e, pn_s_a, :back_kernel, User_Utility_as_Kernel___.new( self )
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

      def to_unbound_action_stream
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
        bx_ = Callback_::Box.new

        amod = __actions_module

        _bx.each_pair do | k, ent |

          if ent._is_defined_

            bx_.add k, ent

          elsif h[ k ]

            # this is just a public method with no option parser.
            # the below hack lets the top invocation find our custom class

            nm = Callback_::Name.via_variegated_symbol k

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

      def model_class
        @_user_utility_class
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

    class Action_Adapter__ < CLI::Action_Adapter_

      def initialize defined_entry, custom_kernel

        @bound = self
        @_nf = defined_entry.name_function
        @_custom_kernel = custom_kernel

        @_settable_by_environment_h = nil  # sux
      end

      def formal_properties
        @__fpx ||= __infer_formal_properties
      end

      def __infer_formal_properties

        o = Here_::Models_::Isomorphic_Method_Parameters.new

        o.method = @_custom_kernel._user_utility.method( @_nf.as_variegated_symbol )

        @_egads = o

        o.execute
      end

      def has_description
        ( @_desc_model ||= __build_description_model ).has_content
      end

      def under_expression_agent_get_N_desc_lines exp, d=nil
        @_desc_model.under_expag_get_N_desc_lines_ exp, d
      end

      def __build_description_model
        Here_::Models_::Help_Screen::Models::Description.of_instance self
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

        @_stx = Here_::Models_::Isomorphic_Method_Parameters.new _ruby_params

        CP___.new do | cp |

          accept_categorized_properties_ cp

          cp.adapter = self

          cp.opt_a = [ CLI::STANDARD_ACTION_PROPERTY_BOX_.fetch( :help ) ]

          cp.arg_a = if @_stx.argument_term_count.nonzero?
            @_stx.to_a
          end
        end
        NIL_
      end

      def produce_populated_option_parser op, opt_a

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

        @seen = Callback_::Box.new  # but we use this (see next method)

        NIL_
      end

      def mutate_backbound_iambic_ prp

        # unlike parent we do not write to @mutable_backbound_iambic so
        # we do a simplified version of things here

        touch_argument_metadata prp.name_symbol

        NIL_
      end

      def write_any_auxiliary_syntax_string y

        # unlike parent which checks for the existence of any property
        # called 'help', we always support this action-like option.

        _ho = CLI::STANDARD_ACTION_PROPERTY_BOX_.fetch :help
        write_auxiliary_syntax_string_for_help_option_ y, _ho
        y
      end

      def bound_call_via_ARGV_

        # the last step: fail because args length or succeed w/ the bound call

        argv = @resources.argv

        bc = @_stx.validate_against_args argv do |o|

          o.on_missing do | miss_ev |

            CLI::When_::Missing_Arguments_Fancy.new miss_ev, help_renderer
          end

          o.on_extra do | xtra_ev |

            CLI::When_::Extra_Arguments.new xtra_ev, help_renderer
          end

          o.on_success do

            NIL_  # invert the usual T/F for succeed/fail
          end
        end

        if bc
          bc
        else

          Callback_::Bound_Call.new(
            argv,
            @_custom_kernel._user_utility,
            @_nf.as_variegated_symbol
          )
        end
      end
    end

    class CP___ < CLI::Categorized_Properties_

      def mutate_help_renderer_ o

        @help_renderer = o
        @opt_a and __add_option_section o
        @arg_a and __add_arg_section o
        # @env_a and __add_env_section o  we never have these
        NIL_
      end
    end

    Here_ = self
    Autoloader_[ Models_ = ::Module.new ]

  end
end