module Skylab::TMX

  class CLI

    class Magnetics_::BoundCall_via_MountAnyInstalledSidesystem  # 1x

      # -

        def initialize possible_entry, cli, inst
          @CLI = cli
          @entry = possible_entry
          @installation = inst
        end

        def match_head_as_participating_gem

          _head = @installation.participating_gem_prefix[ 0...-1 ]  # # => "skylab"
          gem_path = ::File.join _head, @entry
          _yes = ::Gem.try_activate gem_path
          if _yes
            @__gem_path = gem_path
            ACHIEVED_
          end
        end

        def bound_call_for_participating_sidesystem

          # tons of assumptions about names and interfaces.. #hook-out

          o = @CLI
          argv_scn = o.release_ARGV
          _tok = argv_scn.current_token
          argv_scn.advance_one
          argv = argv_scn.flush_remaining_to_array

          _ss_mod = __sidesystem_module

          _cli_class = _ss_mod.const_get :CLI, false

          _pn_s_a = [ * o.program_name_string_array, _tok ]

          _cli = _cli_class.new argv, o.sin, o.sout, o.serr, _pn_s_a do
            o
          end

          _ = _cli.to_bound_call  # ..
          _  # #todo
        end

        def __sidesystem_module

          # we avoid using `const_reduce` (for name correction) unless we
          # need to (for no good reason).
          # this is near but not the same as [#br-083]

          require remove_instance_variable :@__gem_path

          _const_a = @installation.participating_gem_const_path_head

          up_mod = _const_a.reduce ::Object do |mod, const|
            mod.const_get const, false
          end

          const = if DIGITS___ =~ @entry  # workaround until #wish [#co-067]
            @entry.gsub( %r(_?(?<![a-z])([a-z0-9])) ) { $1.upcase }
          else
            _nf = Common_::Name.via_lowercase_with_underscores_string @entry
            _nf.as_camelcase_const_string
          end

          if up_mod.const_defined? const, false
            up_mod.const_get const, false
          else
            Autoloader_.const_reduce [ const ], up_mod
          end
        end

      # -

      module MAYBE_SALVAGE_ME

    def __receive_call x_a, & oes_p

      @_in_st = Common_::Polymorphic_Stream.via_array x_a
      if oes_p
        @on_event_selectively = oes_p
      end
      NIL_
    end

    def __execute

      if @_in_st.no_unparsed_exists
        __when_no_arguments
      else
        __when_some_arguments
      end
    end

  public  # (methods named with bounding underscores are effectively private)

    def __when_no_arguments

      _emit :error, :missing_required_properties, :missing_first_argument do
        _build_event :Missing_First_Argument
      end

      UNABLE_
    end

    def __when_some_arguments

      @first_argument = @_in_st.gets_one

      _nf = Common_::Name.via_variegated_symbol @first_argument

      @unbound = @fast_lookup[ _nf ]

      if @unbound

        __when_unbound

      else

        _emit :error, :no_such_reactive_node do
          _build_event :No_Such_Reactive_Node
        end

        UNABLE_
      end
    end

    attr_reader :first_argument

    attr_accessor(
      :fast_lookup,
      :unbound_stream_builder,
    )

    def __when_unbound

      if @unbound.respond_to? :module_exec  # for now

        @unbound::API.application_kernel_.bound_call_via_polymorphic_stream(
          remove_instance_variable( :@_in_st ),
          & @on_event_selectively )
      else
        self._COVER_ME
      end
    end

    # ~ support

    def _emit * i_a, & ev_p

      @on_event_selectively.call( * i_a, & ev_p )
    end

    def _build_event sym

      Me_::Events_.const_get( sym, false )[ self ]
    end

    class As_Kernel___

      def initialize front
        @_client = front
      end

      def description_proc

        _p = Home_.method :describe_into_under
        -> y do
          _p[ y, self ]
        end
      end

      def fast_lookup
        @_client.fast_lookup
      end

      def build_unordered_selection_stream & x_p
        @_client.unbound_stream_builder.call( & x_p )
      end

      def module
        :__no_module__
      end

      def reactive_tree_seed
        self._ONLY_for_respond_to
      end
    end  # As_Kernel___

    #==FROM

    module Common_Bound_Methods

      # because we aren't mucking with brazen reactive node API, redundant

      def is_visible
        true
      end

      def name_value_for_order
        @nf_.as_const  # b.c already calculated
      end

      def after_name_value_for_order
        NIL_
      end

      def name
        @nf_
      end
    end

    #==TO

      end  # MAYBE_SALVAGE_ME

      # ==

      DIGITS___ = /[0-9]/

      # ==
    end
  end
end
