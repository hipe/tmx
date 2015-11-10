module Skylab::MyTerm

  # (placeholder indentation for would-be :+"that trick" library module)

    class Image_Output_Adapters_::Imagemagick

      # as the first adapter, etc.

      class << self

        def interpret_compound_component p, nf, acs, & oes_p

          p[ new nf, acs, & oes_p ]
        end

        private :new
      end  # >>

      def initialize asc, acs, & oes_p

        @kernel_ = acs.kernel_
        @_nf = asc.name
        @_oes_p = oes_p
      end

      # ~ component association definitions

      def __background_font__component_association

        Home_::Models_::Font
      end

      # ~ my business-specifics as entity (would go up)

      def flush_to_selected_adapter  # see `flush_to_` name convention [#bs-028]
        @is_selected = true
        self
      end

      def path
        @_nf.path
      end

      def adapter_name_const
        @_nf.as_const
      end

      def adapter_name
        @_nf
      end

      attr_reader(
        :is_selected,
      )

      # ~ ACS-related reflection (most/all would go up)

      def read_for_component_interface__ vasc

        ACS_[]::For_Interface::Touch[ vasc.real_association_, self, & @_oes_p ]
      end

      def receive__component__change__ asc, & change

        _ = ACS_[]::Interpretation::Accept_component_change[ self, asc, change ]

        _mutation = _[]

        @_oes_p.call :component, :mutation do
          _mutation
        end
      end

      attr_reader(
        :kernel_,
      )
    end
  # -
end
