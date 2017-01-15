module Skylab::TMX

  class CLI

    module Magnetics_::HelpScreenDidactics_via_TMX_HostClient  # 1x

      # the name "host client" instead of "CLI" is meant to accentuate
      # that although for now this is always the root tmx client, it
      # could just as soon be any other "tmx"

      class << self
        def call cli
          if 1 == cli.selection_stack.length
            ForSelf___.new cli
          else
            AsHost___.new cli
          end
        end
        alias_method :[], :call
      end  # >>

      # ==

      Common__ = ::Class.new

      class AsHost___ < Common__

        def initialize cli
          @CLI = cli
        end

        def description_proc_for k

          # (we should never field requests for mounteds here, because
          # they implement their own help (or don't) autonomously)

          _m = @CLI.class::OPERATOR_DESCRIPTIONS.fetch k
          @CLI.method _m
        end
      end

      # ==

      class ForSelf___ < Common__

        def initialize cli

          @_once = nil ; @_once2 = nil
          @omni = cli.omni
          @client = cli
        end

        def execute
          if 1 < _verbose_count
            self._SANITY___never_get_this_far_when_very_verbose__
          end
          self
        end

        def to_item_normal_tuple_stream
          remove_instance_variable :@_once
          @_eek = {}
          __to_item_normal_tuple_scanner.to_minimal_stream
        end

        def description_proc_reader
          h = remove_instance_variable :@_eek
          -> symbol_or_load_ticket do
            _type_sym = h.fetch symbol_or_load_ticket.intern
            @_describers.fetch( _type_sym )._description_proc_for_ symbol_or_load_ticket
          end
        end

        def __to_item_normal_tuple_scanner
          scn = __to_operator_normal_tuple_scanner
          if @omni.has_primaries  # probably always
            scn.concat_scanner __to_primary_normal_tuple_scanner
          else
            scn
          end
        end

        def __to_operator_normal_tuple_scanner

          scn = __to_reduced_operator_load_ticket_scanner

          scn.map_by do |symbol_or_load_ticket|
            @_eek[ symbol_or_load_ticket.intern ] = scn.current_injection.injector
            [ :operator, symbol_or_load_ticket ]  # [#ze-062] sneak in an l.t not a symbol
          end
        end

        def __to_reduced_operator_load_ticket_scanner

          stay = __to_stay_map

          @omni.to_operator_load_ticket_scanner do |o|
            o.big_step_pass_filter = -> scn do
              k = scn.current_injection.injector
              yes = stay.fetch k
              if yes
                ( @_describers ||= {} )[ k ] = OPER_DESCRIBERS___.fetch( k ).new @client
              end
              yes
            end
          end
        end

        def __to_stay_map

          # whether or not to display a group of operators per injection

          if _verbose_count.nonzero?
            _do_show_mountable_sidesystems = true
          end
          {
            tmx_intrinsic: true,
            tmx_mountable_sidesystem: _do_show_mountable_sidesystems,
          }
        end

        def _verbose_count
          @client.verbose_count_
        end

        def __to_primary_normal_tuple_scanner  # assume has primaries
          ( @_describers ||= {} )[ :primary ] = PrimaryDescriber___.new @client
          @omni.to_primary_symbol_scanner.map_by do |sym|
            @_eek[ sym ] = :primary
            [ :primary, sym ]
          end
        end

        def description_proc
          remove_instance_variable :@_once2
          @client.method :describe_into
        end

        def is_branchy  # decides what kind of screen to use
          true
        end
      end

      # ==

      Same__ = ::Class.new

      class SidesystemDescriber___
        # the big loader
        def initialize _cli
        end
        def _description_proc_for_  load_ticket
          load_ticket.IS_LOAD_TICKET_tmx_ || fail
          -> y do
            _mod = load_ticket.require_sidesystem_module
            _mod.describe_into_under y, self
          end
        end
      end

      class IntrinsicDescriber___ < Same__
        CONST = :OPERATOR_DESCRIPTIONS
      end

      class PrimaryDescriber___ < Same__
        CONST = :PRIMARY_DESCRIPTIONS
      end

      OPER_DESCRIBERS___ = {
        tmx_intrinsic: IntrinsicDescriber___,
        tmx_mountable_sidesystem: SidesystemDescriber___,
      }

      class Same__

        def initialize cli
          @__oper_desc_hash = cli.class.const_get self.class::CONST
          @__implementor = cli
        end

        def _description_proc_for_ xx
          @__implementor.method @__oper_desc_hash.fetch xx
        end
      end

      # ==
    end
  end
end
# #history - abstracted from main CLI file
