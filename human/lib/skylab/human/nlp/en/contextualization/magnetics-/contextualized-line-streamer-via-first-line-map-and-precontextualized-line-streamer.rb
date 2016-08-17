module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::Contextualized_Line_Stream_via_First_Line_Proc_and_Precontextualized_Line_Stream ; class << self  # 2x

      def call p, st

        o = Home_::Sexp::Expression_Sessions::List_through_Eventing::Simple.begin

        o.on_first = -> line do

          lc = Magnetics_::Line_Contextualization_via_Line[ line ]  # the only reference

          _ = p[ lc ]
          _ && Home_._SANITY  # this proc is not a mapper - (we flip-flopped on this) be sure you're using it right # #todo

          lc.to_string__
        end

        o.on_subsequent = IDENTITY_

        _ = o.to_stream_around st

        _  # #todo

      end
      alias_method :[], :call

      # ==

      # ==
    end ; end
  end
end
# #history: broke out of sibling "[etc]..and-selection-stack"
