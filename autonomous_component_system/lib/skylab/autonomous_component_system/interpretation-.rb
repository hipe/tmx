module Skylab::Autonomous_Component_System
  # ->
    module Interpretation_

      class Build_value  # [#006]:the-universal-component-builder explains everything

        class << self
          def _call ma, asc, acs, & oes_p_p
            new( ma, asc, acs, & oes_p_p ).execute
          end
          alias_method :call, :_call
          alias_method :[], :_call
        end  # >>

        def initialize ma, asc, acs, & chb

          if 1 != chb.arity
            self._WORLDWIDE_PROTEST
          end

          @ACS = acs
          @association = asc
          @_CHB = chb
          @construction_method = nil
          @mixed_argument = ma
        end

        attr_writer(
          :construction_method,
          :mixed_argument,
        )

        def looks_like_compound_component__

          @_did_categorize_shape ||= _categorize_supposed_model_shape

         COMPOUND_CONSTRUCTOR_METHOD_ == @_use_construction_method
        end

        def execute

          @_did_categorize_shape ||= _categorize_supposed_model_shape

          if @_CHB

            @_use_CHB = @_CHB
          else
            @_use_CHB = ACS_::Interpretation::CHB[ @association, @ACS ]
          end

          if @_use_construction_method
            __via_construction_method
          else

            @_mdl[ @mixed_argument, & @_CHB ]
          end
        end

        def _categorize_supposed_model_shape

          if @construction_method

            cm = @construction_method

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
          end

          @_mdl = @association.component_model
          @_use_construction_method = cm

          ACHIEVED_
        end

        def __via_construction_method

          m = @_use_construction_method

          if ! @_mdl.respond_to? m
            raise ::NameError, ___say_no_method( m )
          end

          d = @_mdl.method( m ).arity
          if 1 < d
            # see construction args [#006]:interp-C
            xtra = []
            if 2 < d
              xtra.push @association
            end
            xtra.push @ACS
          end

          cmp = @_mdl.send m, @mixed_argument, * xtra, & @_use_CHB
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
