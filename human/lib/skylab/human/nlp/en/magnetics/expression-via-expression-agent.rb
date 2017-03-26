module Skylab::Human

  module NLP::EN

    class Magnetics::Expression_via_ExpressionAgent

      class << self

        alias_method :interpret_component_fully_, :new
        undef_method :new
      end  # >>

      def initialize scn, asc

        @_method_name = scn.gets_one
        @_mixed = scn.gets_one
        scn.assert_empty
      end

      def express_into_under y, expag
        y << expag.send( @_method_name, @_mixed )
      end

      def _difference_against_counterpart_ otr
        if otr._method_name == @_method_name
          if otr._mixed == @_mixed
            NOTHING_
          else
            :_x_
          end
        else
          :_m_
        end
      end

      these = %i( _method_name _mixed )  # names are #testpoint
      attr_reader( * these )
      protected( * these )

      def category_symbol_
        :_for_expag_
      end
    end
  end
end
# #history: broke stowaway out of main file. code is just over a year older than file.
