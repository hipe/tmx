module Skylab::Autonomous_Component_System

  class Parameter

    module Formal_Parameter_Stream_via_Platform_Parameters_and_Formal_Operation

      # 1x here. [#029]

      # like those of component associations, every sub-component of any
      # formal operation is subject to change. this includes the proc
      # that implements the operation (where applicable).

      # in light of the long note after this block about optionals,
      # one aspect we *can* isomorph from the platform proc is a linear
      # order of formal parameters. as such, we do.
      #

      class << self ; def [] a, fo

        if a.length.nonzero? && :block == a.last.first
          # a block (if utilized by the implementer) serves as an event
          # handler builder; and in any case receives no expression here.
          a.pop
        end

        any_bx = fo.box
        use_bx = if any_bx
          any_bx
        else
          MONADIC_EMPTINESS_
        end

        Callback_::Stream.via_nonsparse_array a do |(cat, sym)|

          edit = PARAM_ARITY___.fetch cat

          existing = use_bx[ sym ]

          if existing
            if edit
              existing.dup_by_ do
                instance_exec( & edit )
                @parameter_arity ||= :one
              end
            elsif existing.parameter_arity
              existing
            else
              existing.dup_by_ do
                @parameter_arity = :one
              end
            end
          else
            Here_.new_by_ do
              if edit
                instance_exec( & edit )
              end
              @parameter_arity ||= :one
              @name_symbol = sym
            end
          end
        end
      end ; end

      PARAM_ARITY___ = {
        req: NOTHING_,
        rest: -> do
          @argument_arity = :zero_or_more
          @parameter_arity = :zero_or_more
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
