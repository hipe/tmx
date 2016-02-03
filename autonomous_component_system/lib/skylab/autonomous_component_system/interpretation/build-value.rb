module Skylab::Autonomous_Component_System

  module Interpretation

    class Build_value  # result is a qk
      # -
        # [#006]:the-universal-component-builder explains everything

        class << self
          def _call ma, asc, acs, & oes_p_p
            new( ma, asc, acs, & oes_p_p ).execute
          end
          alias_method :call, :_call
          alias_method :[], :_call

          alias_method :begin, :new
          private :new
        end  # >>

        def initialize ma, asc, acs, & pp

          if pp && 1 != pp.arity
            self._WORLDWIDE_PROTEST
          end

          @ACS = acs
          @association = asc
          @construction_method = nil
          @emission_handler_builder = pp
          @mixed_argument = ma
        end

        attr_writer(
          :construction_method,
          :mixed_argument,
        )

        def looks_like_compound_component__

          @_did_prepare_call ||= _prepare_call

          COMPOUND_CONSTRUCTOR_METHOD_ == @_explicit_method_name
        end

        def execute

          @_did_prepare_call ||= _prepare_call

          @_oes_p_p = if @emission_handler_builder
            @emission_handler_builder
          else
            Build_emission_handler_builder_[ @association, @ACS ]
          end

          if @_explicit_method_name
            __via_construction_method
          else
            ___via_proc_like_call
          end
        end

        def ___via_proc_like_call
          kn = @_receiver[ @mixed_argument, & @_oes_p_p ]
          if kn
            kn.to_qualified_known_around @association
          else
            kn
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
          @_explicit_method_name = cm

          ACHIEVED_
        end

        def __via_construction_method

          m = @_explicit_method_name

          if ! @_receiver.respond_to? m
            raise ::NameError, ___say_no_method( m )
          end

          d = @_receiver.method( m ).arity
          if 1 < d
            # see construction args [#006]:the-super-signature
            xtra = []
            if 2 < d
              xtra.push @association
            end
            xtra.push @ACS
          end

          cmp = @_receiver.send m, @mixed_argument, * xtra, & @_oes_p_p
          if cmp
            Callback_::Qualified_Knownness[ cmp, @association ]
          else
            cmp
          end
        end

        def ___say_no_method m

          x = @_receiver
          _ = if x.respond_to? :name
            x.name
          else
            "#{ x }"
          end
          # platform reporting of class name is not as helpful as it could be
          "undefined method `#{ m }` for #{ _ }"
        end
      # -
    end
  end
end
