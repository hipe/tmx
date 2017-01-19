module Skylab::Brazen

  class CLI

    class Adapter_Producer___

      # effect the policy of (and caches knowledge about) the various
      # constant-space (and filesystem) locations that can be used (relative
      # to something) to hold any per-node custom adapters.

      # this is the implementation of the hook-points documented at [#062].

      def initialize up_bnd, up_ada

        # first: if the unbound *itself* specifies a (#goofy-direction)
        # custom modality-specific adapter for this modality, use this.

        # second: if the adapter class had defined its own "Actions" module,
        # look in that and use any adapter there (lots more at [#062])

        # third: if the silo module of the unbound has a "modalities" module,
        # we'll be looking in there too.

        # finally: the base case is to use upward-cascading to look at each
        # adapter in the UI tree upwards until finishing with the top (at
        # present only our own) which must define some adapter class to use.

        a = [ Always_try_this___ ]

        mod = up_ada.const_get_magically_ :Actions
        if mod
          a.push __look_in_actions_module mod
        end

        a.push Always_try_this_too___

        a.push The_base_case___[ up_ada ]

        @_try_these = a

        @_upper_adapter = up_ada
        @_upper_bound = up_bnd
      end

      def adapter_for_unbound unb

        _ada_cls = ___some_adapter_class_for unb

        _ada_cls.new unb, @_upper_bound
      end

      def ___some_adapter_class_for unb

        @_try_these.reduce nil do | _, p |
          x = p[ unb ]
          x and break x
        end
      end

      Always_try_this___ = -> unb do  # first

        unb.adapter_class_for :CLI
      end

      def __look_in_actions_module actions_module  # second

        -> unb do
          const = unb.name_function.as_const
          if actions_module.const_defined? const, false
            actions_module.const_get const, false
          end
        end
      end

      _CLI_node_for = nil

      Always_try_this_too___ = -> unb do

        _CLI = _CLI_node_for[ unb ]
        if _CLI

          if _CLI.respond_to? :new  # [cme] .. experimental
            _CLI

          else  # [gi] "branches"
            # the below has the side-effect of requiring etc..

            mod = _CLI.const_get :Actions, false
            if mod
              const = unb.name_function.as_const
              if mod.const_defined? const, false
                mod.const_get const, false
              end
            end
          end
        end
      end

      _SLUG = 'modalities'

      _CLI_node_for = -> unb do

        # whether branch or ([bs] delit.) leaf, if it has a "silo module",

        sm = unb.silo_module
        if sm

          # peek into the filesystem (where available) to see if the
          # corresponding file is there, to determine if it's ok to touch
          # the const to kick autoloading when possible and necessary.
          #
          # maybe wish we had #[#101] const get magically.
          #
          # maybe #wish-for-proper-autoloading

          if sm.respond_to? :entry_tree
            ft = sm.entry_tree
            if ft
              _sm = ft.asset_ticket_via_entry_group_head _SLUG
              if _sm
                sm.const_get :Modalities, false
              end
            end
          end

          # now that it has been loaded (when existent),

          if sm.const_defined? :Modalities, false
            sm::Modalities::CLI  # sanity assumption only for now
          end
        end
      end

      The_base_case___ = -> upper_ada do

        -> unb do

          if unb.is_branch
            upper_ada.branch_adapter_class_
          else
            upper_ada.leaf_adapter_class_
          end
        end
      end
    end
  end
end
