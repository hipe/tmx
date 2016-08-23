module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::Lemmato_Trilean_Idiom_via_Trilean ; class << self

      def via_magnetic_parameter_store ps
        x = ps._read_magnetic_value_with_certainty_ :trilean
        if x
          __when_successful ps
        elsif x.nil?
          __when_neutral ps
        else
          __when_failed ps
        end
      end
      alias_method :[], :via_magnetic_parameter_store

      def __when_failed ps
        x = ps.idiom_for_failure
        if x
          Const_via_idiom_[ x, ps ]
        elsif ps.subject_association
          :Is_Predicate_Mode_Couldnt_Frob_Because
        else
          :Is_Failed_To_Frob
        end
      end

      def __when_neutral ps
        x = ps.idiom_for_neutrality
        if x
          Const_via_idiom_[ x, ps ]
        elsif ps.subject_association
          :Is_Predicate_Mode_While_Frobbing
        else
          :Is_While_Frobbing
        end
      end

      def __when_successful ps
        x = ps.idiom_for_success
        if x
          Const_via_idiom_[ x, ps ]
        elsif ps.subject_association
          :Is_Predicate_Mode_Frobbed
        else
          :Is_Frobbed
        end
      end

    end ; end
  end
end
# #history: broke out of sibling file
