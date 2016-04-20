module Skylab::SearchAndReplace

  module CLI

    class << self

      def new sin, sout, serr, pn_s_a

        _pr = Prototype___[]
        inst = _pr.dup
        inst.universal_CLI_resources sin, sout, serr, pn_s_a
        inst.finish
      end

      def highlighting_expression_agent_instance__
        @___hl_expag ||= Highlighting_Expag___.new
      end
    end  # >>

    Prototype___ = Lazy_.call do

      # _ = rsx.bridge_for( :filesystem ).pwd

      Require_Zerk_[]
      cli = Zerk_::HybridCLI.begin

      cli.root_ACS = -> & top_oes_p do
        acs = Root_Autonomous_Component_System_.new( & top_oes_p )
        acs._init_with_defaults
        acs
      end

      cli.interactive_design = -> vmm do
        vmm.compound_frame = vmm.common_compound_frame
        vmm.custom_tree = CUSTOM_TREE_
        vmm.location = vmm.common_location
        vmm.primitive_frame = vmm.common_primitive_frame
        vmm
      end

      cli.location_module = CLI

      cli
    end

    # ==

    module NonInteractive
      module CustomEffecters
        module Search
          Replace = -> x, cli do
            CLI::NonInteractive_ViewEffecters::Replace_All_in_File.via__( x, cli ).execute
          end
        end
      end
    end

    # ==

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
