module Skylab::Snag

  class CLI < Snag_.lib_.brazen::CLI

    class << self

      def new * a

        new_top_invocation a, Snag_.application_kernel_
      end
    end  # >>

    # ~ the bulk of this file is the implementation of the hybrid "open"
    # action adapter, an exposure that calls one of two distinct model
    # actions depending on its arguments.

    def to_child_unbound_action_stream

      # this is :[#br-066] currently the only example of the code
      # necessary to expose & implement a modality-only action adatper..

      super.unshift_by CLI::Mock_Unbound.new( Actions::Open )
    end

    class Action_Adapter < Action_Adapter

      MUTATE_THESE_PROPERTIES = [ :upstream_identifier ]

      def mutate__upstream_identifier__properties

        mutable_front_properties.replace_by :upstream_identifier do | prp |

          prp.dup.set_default_proc do

            present_working_directory

          end.freeze
        end

        NIL_
      end
    end

    Actions::Open = ::Class.new Action_Adapter  # will re-open

    class Actions::Open::Mock_Bound < CLI::Mock_Bound

      # .. we have to make one of these when don't have a backstream action

      def describe_into_under y, expag

        y << "open an issue or stream open issues"
      end

      attr_reader :_keys_that_pertain_to_create_only,
        :_keys_that_pertain_to_report_only,
        :_the_create_action

      def produce_formal_properties

        mod = Snag_::Models_::Node::Actions

        @_the_create_action = mod::Open
          # (we are dreaming of persisted macros instead)

        bx = @_the_create_action.properties.to_new_mutable_box_like_proxy

        __modify_properties_that_pertain_to_create bx

        __add_properties_that_pertain_to_report bx

        bx
      end

      # ~

      def __modify_properties_that_pertain_to_create bx

        # make the message optional not required; the defining mechanic

        bx.replace_by :message do | prp |

          prp.new_with(
            :argument_arity, :zero_or_more,
            :parameter_arity, :zero_or_one,
            :description, -> y do
              y << "if provided, act similar to `node open`"
              y << "(and all above options pertain unless stated)"
              y << "otherwise run \"open\" report or equivalent"
            end )
        end
        NIL_
      end

      # ~

      def __add_properties_that_pertain_to_report bx

        a = []
        ks = bx.get_names

        PROPERTIES_FOR_REPORT___.to_value_stream.each do | prp |

          k = prp.name_symbol
          had = true
          bx.touch k do
            had = false
            prp
          end

          if had
            d = ks.index k
            ks[ d ] = nil
            ks.compact!
          else
            a.push k
          end
        end

        @_keys_that_pertain_to_create_only = ks
        @_keys_that_pertain_to_report_only = a

        NIL_
      end

      def __produce_number_limit_property prp

        otr = prp.dup_with(
          :description, -> y do
            y << "`-<number>` too"
          end )

        __mutate_property_by_adding_description_wrapper otr
        otr
      end

      def __mutate_property_by_adding_description_wrapper otr

        def otr.under_expression_agent_get_N_desc_lines expag, d=nil
          s_a = super expag, d
          s_a[ 0 ] = "(when listing:) #{ s_a.fetch 0 }"
          s_a
        end
        NIL_
      end
    end

    Brazen_ = ::Skylab::Brazen

    PROPERTIES_FOR_REPORT___ = Brazen_::Model.make_common_common_properties(
    ) do | sess |

      _prp_a = Snag_::Models_::Node::Actions::To_Stream.
        properties.at :number_limit, :upstream_identifier

      sess.edit_common_properties_module :reuse, _prp_a

    end

    class Actions::Open  # re-open

      # ~ hook-ins

      def produce_populated_option_parser op, opt_a

        op = super

        CLI.superclass::Option_Parser::Experiments::Regexp_Replace_Tokens.new(
          op,
          %r(\A-(?<num>\d+)\z),
          -> md do
            [ '--number-limit', md[ :num ] ]
          end )
      end

      def prepare_backstream_call x_a

        @_filesystem = Snag_.lib_.system.filesystem
        @_oes_p = handle_event_selectively

        ok = __process_all_backbound_arguments_now x_a
        ok &&= __normalize_all_actuals_now
        ok && __resolve_bound_action_appropriately
      end

      # ~ we do this early as an easy way to tackle the shared processing
      # for those formal(s) that exist in both "actions"; at the cost of
      # this node needing to know the whole set union of all properties,
      # and needing to write the common normalization steps itself.

      # because we don't have a normal action (for now), we will need to
      # trigger "manually" the normalizations of those formals with them.

      def __process_all_backbound_arguments_now x_a

        @number_limit = nil
        @upstream_identifier = nil

        _st = Callback_::Polymorphic_Stream.via_array x_a

        kp = Callback_::Actor::Methodic::
          Process_polymorphic_stream_fully.call _st, self

        if kp
          x_a.clear
        end

        kp
      end

    private

      def number_limit=

        prp = @bound.formal_properties.fetch :number_limit

        _x = @polymorphic_upstream_.gets_one

        arg = prp.normalize_argument(
          Callback_::Trio.via_value_and_property( _x, prp ),
          & @_oes_p )

        if arg
          @number_limit = arg.value_x
          KEEP_PARSING_
        else
          UNABLE_  # "downgrade" nil to false to get invites
        end
      end

      def upstream_identifier=
        @upstream_identifier = @polymorphic_upstream_.gets_one
        KEEP_PARSING_
      end

      # ~

      def __normalize_all_actuals_now

        path = @upstream_identifier
        prp = @mutable_front_properties.fetch :upstream_identifier

        if ! path
          path = prp.default_proc.call
        end

        path or self._SANITY

        path = Snag_::Models_::Node_Collection.nearest_path(
          path, @_filesystem, & @_oes_p )

        if path
          @upstream_identifier = path
          ACHIEVED_
        else
          path
        end
      end

      # ~

      def __resolve_bound_action_appropriately

        if @seen[ :message ]
          self._TODO_init_bound_ivar_for_create
        else
          __resolve_bound_action_for_report
        end
      end

      def __resolve_bound_action_for_report

        bnd = @bound

        bad_a = @seen.a_ & bnd._keys_that_pertain_to_create_only

        if bad_a.length.zero?

          __flush_resolution_of_bound_report
        else

          _when_bad bad_a,
            _Report_of_Open_Nodes.name_function,
            bnd._the_create_action.name_function
        end
      end

      def __flush_resolution_of_bound_report

        o = _Report_of_Open_Nodes.new( & @_oes_p )
        o.filesystem = @_filesystem
        o.kernel = @parent.bound_
        o.name = name
        o.number_limit = @number_limit
        o.upstream_identifier = @upstream_identifier

        @bound = o
        ACHIEVED_
      end

      def _Report_of_Open_Nodes
        Snag_::Models_::Node_Collection::Sessions::Report_of_Open_Nodes
      end

      # ~ shared

      def _when_bad bad_sym_a, wont_work_for_this, but_this

        bx = @bound.formal_properties

        prop_a = bad_sym_a.map do | k |
          bx.fetch k
        end

        receive__error__expression :non_pertinent_arguments do | y |

          _s_a = prop_a.map do | prp |
            par prp
          end

          _ = and_ _s_a

          _no = wont_work_for_this.name_function.as_slug

          _ok = but_this.name_function.as_slug

          y << "#{ _ } can be used for #{ val _ok } but not for #{ val _no }"
        end
        UNABLE_  # ("downgrade" result of above from nil to false)
      end
    end

    # ~ begin :+#hook-out for tmx
    Client = self
    module Adapter
      module For
        module Face
          module Of
            Hot = -> x, x_ do
              Brazen_::CLI::Client.fml Snag_, x, x_
            end
          end
        end
      end
    end
    # ~ end
  end
end
