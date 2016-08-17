module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::Precontextualized_Line_Stream_via_Emission_that_Is_Expression ; class << self

      def via_magnetic_parameter_store ps

        # we assume that since you are contextualizing, you will probably
        # want all of the lines from the emission too (otherwise see
        # [#ba-030] "N lines").
        #
        # this choice makes implementation and debugging easier if we can
        # flush all the "raw" lines in one step rather than being OCD about
        # streaming but note this is a hidden implementation decision.
        # (this comment is referenced by sibling.)

        a = []

        _y = ::Enumerator::Yielder.new do |s|
          a << Plus_newline_if_necessary_[ s ]
        end

        ps.expression_agent.calculate _y, & ps.emission_proc

        Common_::Stream.via_nonsparse_array a
      end

      alias_method :[], :via_magnetic_parameter_store
    end ; end
  end
end
# #history: broke out of "emission via expression"
