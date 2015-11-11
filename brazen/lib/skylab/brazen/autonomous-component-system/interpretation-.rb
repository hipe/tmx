module Skylab::Brazen

  module Autonomous_Component_System

    module Interpretation_

      class Build_Value

        # NOTE this results in a wrapped value, not the component itself!
        # (so that it looks the same whether it's the one or the other means)

        # the only purpose this node serves is to implement :t5 and :t6
        # (realizing the API exposures `[]` and `interpret_component`),
        # and the only node that knows of those tenets is this one.

        # this does not assign child to parent in any way, nor does it check
        # if there is already an existing child in any sort of parent member
        # "slot".

        # if the caller wants the child to have a one-way/passive/blind
        # connection to parent, it may do by passing an appropriate handler,
        # or building one with a macro avaiable below.

        # see [#083]:note-INTERP-A for *even more* about this.

        def initialize asc, acs, & oes_p

          @ACS = acs
          @association = asc
          @construction_method = nil
          @mixed_argument = nil
          @on_event_selectively = oes_p
          @_wrap_handler = nil
        end

        def use_empty_argument_stream
          @mixed_argument =
            Callback_::Polymorphic_Stream.the_empty_polymorphic_stream
          NIL_
        end

        def wrap_handler_as_component_handler
          @_wrap_handler = ACS_::Interpretation::Component_handler ; nil
        end

        attr_writer(
          :construction_method,
          :mixed_argument,
        )

        def execute

          component_handler  # init if necessary

          @_mdl = @association.component_model

          if @construction_method

            _via_construction_method @construction_method

          elsif @association.model_looks_like_proc

            @_mdl[ @mixed_argument, & @component_handler ]

          else

            m = @association.construction_method_name

            if m
              _via_construction_method m
            else
              raise ::NoMethodError, @assocation.say_no_method
            end
          end
        end

        def handler_for_component

          x = @_wrap_handler
          @_wrap_handler = nil
          oes_p = x[ @association, @ACS, & @on_event_selectively ]
          @on_event_selectively = oes_p
          oes_p
        end

        def component_handler
          @component_handler ||= ___component_handler
        end

        def ___component_handler

          oes_p = @on_event_selectively

          if @_wrap_handler
            oes_p = @_wrap_handler[ @association, @ACS, & oes_p ]
          end

          oes_p
        end

        def _via_construction_method m

          if ! @_mdl.respond_to? m
            raise ::NameError, ___say_no_method( m )
          end

          d = @_mdl.method( m ).arity
          if 1 < d
            # see construction args :#INTERP-C.
            xtra = []
            if 2 < d
              xtra.push @association
            end
            xtra.push @ACS
          end

          cmp = @_mdl.send m, @mixed_argument, * xtra, & @component_handler
          if cmp
            Value_Wrapper[ cmp ]
          else
            cmp
          end
        end

        def ___say_no_method m
          # platform reporting of class name is not as helpful as it could be
          "undefined method `#{ m }` for #{ @_mdl.name }"
        end
      end

      write_via_ivar = nil

      Writer = -> acs do

        if acs.respond_to? WRITE_METHOD__
          acs.method WRITE_METHOD__
        else
          -> qkn do
            write_via_ivar[ qkn, acs ]
          end
        end
      end

      write = nil
      Write_value = -> x, asc, acs do

        _ = Callback_::Qualified_Knownness.via_value_and_association x, asc
        write[ _, acs ]
      end

      write = -> qkn, acs do

        if acs.respond_to? WRITE_METHOD__
          acs.send WRITE_METHOD__, qkn
        else
          write_via_ivar[ qkn, acs ]
        end
      end

      write_via_ivar = -> qkn, acs do

        if qkn.is_known_known
          acs.instance_variable_set qkn.name.as_ivar, qkn.value_x
        else
          self._DESIGN_ME_cover_me  # e.g etc
        end
        NIL_
      end

      WRITE_METHOD__ = :accept_component_qualified_knownness
    end
  end
end
