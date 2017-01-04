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
          argv_scn = o.release_ARGV__
          _tok = argv_scn.current_token
          argv_scn.advance_one
          argv = argv_scn.flush_remaining_to_array

          _ss_mod = __sidesystem_module

          _cli_class = _ss_mod.const_get :CLI, false

          _pn_s_a = [ * o.program_name_string_array, _tok ]

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

      # ==

      DIGITS___ = /[0-9]/

      # ==
    end
  end
end
