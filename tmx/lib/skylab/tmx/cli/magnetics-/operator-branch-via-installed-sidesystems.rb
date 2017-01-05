module Skylab::TMX

  class CLI

    class Magnetics_::OperatorBranch_via_InstalledSidesystems <  # 1x
        ::NoDependenciesZerk::SimpleModel

      # tons of assumptions about names and interfaces.. #hook-out

      # -

        def initialize
          yield self
          @__head = @installation.participating_gem_prefix[ 0...-1 ]  # "skylab"
          freeze
        end

        attr_writer(
          :CLI,
          :installation,
        )

        def to_normal_symbol_stream
          $stderr.puts "\n«YIKES don't forget - this stub in [tmx] - no fuzzy for sidesystem yet»\n\n"
          EMPTY_P_
        end

        def lookup_softly sym
          entry = sym.id2name  # keep underscores for gem names
          gem_path = ::File.join @__head, entry  # "skylab/punjabi"
          _yes = ::Gem.try_activate gem_path
          if _yes
            _slug = entry.gsub UNDERSCORE_, DASH_
            LoadTicket___.new gem_path, _slug, entry, @installation
          end
        end

        def bound_call_via_load_ticket__ load_ticket
          load_ticket.bound_call_for @CLI
        end
      # -

      class LoadTicket___

        def initialize gp, sl, entry, inst
          @entry = entry
          @gem_path = gp
          @installation = inst
          @slug = sl
          freeze
        end

        def bound_call_for o  # CLI

          scn = o.release_argument_scanner_for_sidesystem_mount__
          if scn.is_closed
            argv = EMPTY_A_
          else
            d, argv = scn.close_and_release
            argv[ 0, d ] = EMPTY_A_
          end

          _ss_mod = __sidesystem_module

          _cli_class = _ss_mod.const_get :CLI, false

          _pn_s_a = [ * o.program_name_string_array, @slug ]

          _cli = _cli_class.new argv, o.sin, o.sout, o.stderr, _pn_s_a do
            o
          end

          _ = _cli.to_bound_call  # ..
          _  # #todo
        end

        def __sidesystem_module

          # we avoid using `const_reduce` (for name correction) unless we
          # need to (for no good reason).
          # this is near but not the same as [#br-083]

          require @gem_path

          _const_a = @installation.participating_gem_const_path_head

          up_mod = _const_a.reduce ::Object do |mod, const|
            mod.const_get const, false
          end

          const = if DIGITS___ =~ @entry# workaround until #wish [#co-067]
            @entry.gsub( %r(_?(?<![a-z])([a-z0-9])) ) { $1.upcase }
          else
            _nf = Common_::Name.via_lowercase_with_underscores_string @entry
            _nf.as_camelcase_const_string
          end

          if up_mod.const_defined? const, false
            up_mod.const_get const, false
          else
            _ = Autoloader_.const_reduce [ const ], up_mod
            _
          end
        end
      end

      # ==

      DIGITS___ = /[0-9]/
      EMPTY_A_ = [].freeze

      # ==
    end
  end
end
