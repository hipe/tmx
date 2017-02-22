module Skylab::Snag::TestSupport

  module Criteria::Magnetics  # (disciple of [pa] t.s)

    def self.[] mod
      mod.include self
      def mod.subject_module_
        Home_::Models_::Criteria::Library_
      end
    end

    def parse_against_ * s_a, & x_p
      against_ input_stream_via_array( s_a ), & x_p
    end

    def against_ in_st, & x_p

      _obj = subject_object_
      _context = grammatical_context_

      _obj.interpret_out_of_under_ in_st, _context, & x_p
    end

    define_method :grammatical_context_for_singular_subject_number_, -> do

      x = nil
      -> do
        x ||= subject_module_::Grammatical_Context_.with :subject_number, :singular
      end
    end.call

    def input_stream_containing * s_a
      input_stream_via_array s_a
    end

    def input_stream_via_array s_a
      Home_.lib_.parse_lib::Input_Streams_::Array.new s_a
    end

    def visual_tree_against_ st
      _x = against_ st
      _x.to_ascii_visualization_string_
    end

    def subject_module_
      self.class.subject_module_
    end
  end
end
# #history: broke out of toplevel t.s
