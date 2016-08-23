module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::First_Line_Map_via_Lemmas_and_Lemmato_Trilean_Idiom::Idiom_that_Is_Custom ; class << self

      def via_magnetic_parameter_store ps

        p = ps.custom_idiom_proc__

        -> line do

          _lc = Magnetics_::Line_Contextualization_via_Line[ line ]
          p[ _lc, ps ]
        end
      end

      alias_method :[], :via_magnetic_parameter_store
    end ; end
  end
end
