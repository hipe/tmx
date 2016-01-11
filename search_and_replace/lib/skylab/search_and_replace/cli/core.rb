module Skylab::SearchAndReplace

  module CLI

    class << self

      def new sin, sout, serr, pn_s_a

        # _ = rsx.bridge_for( :filesystem ).pwd

        cli = Home_.lib_.zerk::InteractiveCLI.new(

          sin, sout, serr, pn_s_a

        ) do | rsx, & top_oes_p |  # todo - don't need resources

          acs = Root_Autonomous_Component_System__.new( & top_oes_p )
          acs._init_with_defaults
          acs
        end

        cli.design = -> vmm do

          vmm.compound_frame = vmm.common_compound_frame
          vmm.custom_tree = CUSTOM_TREE___
          vmm.location = vmm.common_location
          vmm.primitive_frame = vmm.common_primitive_frame
          vmm
        end

        cli
      end

      def highlighting_expression_agent_instance__
        @___hl_expag ||= Highlighting_Expag___.new
      end
    end  # >>

    class Highlighting_Expag___

      def map_match_line_stream st

        # produce a stream that "highlights" the entirety of each line in
        # the upstream in a manner that keeps any trailing newline sequence
        # out of the highlighted span so that any subsequent `puts`, `chomp`
        # etc will still behave as expected on a line that has been styled.
        #
        # this expag prototype is stateless and and as such the particular
        # styling of this highlight is for now hard-coded.

        st.map_by do | line |

          newline_seqence = Mutate_by_my_chomp_[ line ]

          "\e[1;32m#{ line }\e[0m#{ newline_seqence }"
        end
      end
    end
  end
end
