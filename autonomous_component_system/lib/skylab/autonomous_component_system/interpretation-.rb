module Skylab::Autonomous_Component_System
  # ->
    module Interpretation_

      class Build_value  # [#006]:the-universal-component-builder explains everything

        # corroboration by: [ze]

        class << self
          def _call ma, asc, acs, & oes_p_p
            new( ma, asc, acs, & oes_p_p ).execute
          end
          alias_method :call, :_call
          alias_method :[], :_call
        end  # >>

        def initialize ma, asc, acs, & p

          if 1 != p.arity
            self._WORLDWIDE_PROTEST
          end

          @ACS = acs
          @association = asc
          @_argument_oes_p_p = p
          @construction_method = nil
          @mixed_argument = ma
        end

        attr_writer(
          :construction_method,
          :mixed_argument,
        )

        def looks_like_compound_component__

          @_did_prepare_call ||= _prepare_call

         COMPOUND_CONSTRUCTOR_METHOD_ == @_use_construction_method
        end

        def execute

          @_did_prepare_call ||= _prepare_call

          if @_argument_oes_p_p

            @_oes_p_p = @_argument_oes_p_p
          else
            @_oes_p_p = ACS_::Interpretation::CHB[ @association, @ACS ]
          end

          if @_use_construction_method
            __via_construction_method
          else

            @_receiver[ @mixed_argument, & @_oes_p_p ]
          end
        end

        def _prepare_call

          if @construction_method

            cm = @construction_method
            recvr = @association.component_model

          else
            cx = @association.model_classifications
            if ! cx.looks_primitivesque
              m = cx.construction_method_name
              if m
                cm = m
              else
                raise ::NoMethodError, @association.say_no_method__
              end
            end
            recvr = @association.component_model
          end

          @_receiver = recvr
          @_use_construction_method = cm

          ACHIEVED_
        end

        def __via_construction_method

          m = @_use_construction_method

          if ! @_receiver.respond_to? m
            raise ::NameError, ___say_no_method( m )
          end

          d = @_receiver.method( m ).arity
          if 1 < d
            # see construction args [#006]:interp-C
            xtra = []
            if 2 < d
              xtra.push @association
            end
            xtra.push @ACS
          end

          cmp = @_receiver.send m, @mixed_argument, * xtra, & @_oes_p_p
          if cmp
            Value_Wrapper[ cmp ]
          else
            cmp
          end
        end

        def ___say_no_method m
          # platform reporting of class name is not as helpful as it could be
          "undefined method `#{ m }` for #{ @_receiver.name }"
        end
      end

      Writer = -> acs do

        if acs.respond_to? WRITE_METHOD__
          acs.method WRITE_METHOD__
        else
          ACS_::Reflection::Ivar_based_value_writer[ acs ]
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
          Write_via_ivar[ qkn, acs ]
        end
      end

      Write_via_ivar = -> qkn, acs do

        if qkn.is_known_known
          acs.instance_variable_set qkn.name.as_ivar, qkn.value_x
        else
          self._DESIGN_ME_cover_me  # e.g etc
        end
        NIL_
      end

      WRITE_METHOD__ = :accept_component_qualified_knownness
    end
  # -
end
