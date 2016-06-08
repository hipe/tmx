module Skylab::Zerk::TestSupport

  module Fixture_Top_ACS_Classes

    class Class_43_Complexica

      # bespoke for one test suite (for #effecters),
      # we want an operation that is at least one level down,
      # and this operation should produce a stream,
      # and each item in this stream does not express in a conventional way..

      class << self
        alias_method :new_cold_root_ACS_for_niCLI_test, :new
        private :new
      end  # >>

      def __wittgenshtein__component_association
        Witt
      end

      # ==

      class Witt

        class << self
          def interpret_compound_component p
            p[ new ]
          end
          private :new
        end  # >>

        # etc.

        def __nopeka__component_operation

          -> do

            _a = [ Myterio_Effecter.new( nil, nil ) ]
            Common_::Stream.via_nonsparse_array _a
          end
        end

        def __topeka__component_operation

          -> do
            a = []

            a.push Myterio_Effecter.new( 0, [ "shopluka", "boluka"] )
            a.push Myterio_Effecter.new( 7, [ "wopeego" ] )
            a.push Myterio_Effecter.new( 6, [ "diligente" ] )

            Common_::Stream.via_nonsparse_array a
          end
        end
      end

      # ==

      class Myterio_Effecter

        def initialize d, s_a
          @d = d
          @s_a = s_a
        end

        attr_reader(  # for custom effecter only
          :d,
          :s_a,
        )
      end
    end
  end
end
