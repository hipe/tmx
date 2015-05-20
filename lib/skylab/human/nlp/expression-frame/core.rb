module Skylab::Human

  class NLP::Expression_Frame

    class << self

      def match_for_idea idea
        EF_::Actors_::Build_score_against_idea_of_frame[ idea, self ]
      end

      def new_via_iambic x_a  # assume receiver is an e.f subclass

        new_via_idea EF_::Models_::Idea.new_via_iambic x_a
      end

      def new_via_idea x
        new x
      end

      private :new
    end  # >>

    def to_string_with_punctuation_hack_ s_a

      st = Callback_::Polymorphic_Stream.via_array s_a

      s_a_ = [ st.gets_one ]
      while st.unparsed_exists
        s = st.gets_one
        if PUNCT_RX___ !~ s
          s_a_.push SPACE_
        end
        s_a_.push s
      end
      s_a_ * EMPTY_S_
    end

    Autoloader_[ Models_ = ::Module.new ]

    class Models_::Argument_Adapter

      undef_method :to_s

      def initialize & edit_p
        instance_exec( & edit_p )
      end

      Autoloader_[ self ]
    end

    EF_ = self
    PUNCT_RX___ = /\A[:,]/  # etc
  end
end
