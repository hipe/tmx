module Skylab::Autonomous_Component_System

  class Parameter

    module Box_via_platform_params_and_metadata

      # like those of component associations, every sub-component of any
      # formal operation is subject to change. this includes the proc
      # that implements the operation (where applicable).

      # in light of the long note after this block about optionals,
      # one aspect we *can* isomorph from the platform proc is a linear
      # order of formal parameters. as such, we do.

      class << self ; def [] a, fo

        out_bx = Callback_::Box.new

        if a.length.nonzero? && :block == a.last.first
          # a block (if utilized by the implementor) serves as an event
          # handler builder; and in any case receives no expression here.
          a.pop
        end

        any_bx = fo.box
        use_bx = if any_bx
          any_bx
        else
          MONADIC_EMPTINESS_
        end

        a.each do | cat, sym |

          edit = PARAM_ARITY___.fetch cat

          existing = use_bx[ sym ]

          _add_me = if existing
            existing.dup.instance_exec do
              @parameter_arity ||= :one
              if edit
                instance_exec( & edit )
              end
              self
            end
          else
            Here_.new_by__ do
              @parameter_arity = :one
              if edit
                instance_exec( & edit )
              end
              @name_symbol = sym
            end
          end

          out_bx.add sym, _add_me
        end

        out_bx
      end ; end

      PARAM_ARITY___ = {
        req: NOTHING_,
        rest: -> do
          self._SPECIAL
        end,
      }

      # as referenced above, in various ways we have tried to support the
      # isomorphicism that an optional (platform) parameter would express
      # "as expected" in interfaces BUT there are two problems with this:
      #
      #   • there is no "optional" platform parameter per se, only
      #     defaults. we cannot access these defaults through reflection,
      #     so putting them in our pipelines (for expression or otherwise)
      #     is not possible.
      #
      #   • ordered parameters necessarily effect defaults in an order-
      #     contingent way. what this amounts to is that ordered params
      #     with defaults do not isomorph with named arguments with
      #     defaults. for example:
      #
      #         def wazoo arg1=:foo, arg2=:bar, arg3=:baz
      #           # ..
      #         end
      #
      #         # imagine an API call like:
      #
      #         shoe.call :wazoo, :arg1, :val1, :arg3, :val3
      #
      #         # what we would like is to realize the platform default for
      #         # `arg2` when we come around to calling the platform method,
      #         # but it is not possible.
      #
      # this was first realized in [#004]:no-defaults

    end
  end
end
