module Skylab::Headless

  module CLI::Action  # #storypoint-5 in [#039] the CLI action narrative

    def self.[] mod, * x_a
      Bundles__.apply_iambic_on_client x_a, mod
    end

    module Bundles__
      Anchored_names = -> x_a do
        module_exec x_a, & Headless::Action::Bundles::Anchored_names
      end
      Client_services = -> x_a do
        module_exec x_a, & Headless::Action::Bundles::Client_services
      end
      Core_instance_methods = -> _ do
        include CLI::Action::IMs ; nil
      end
      Default_action = -> x_a do
        module_exec x_a.shift, & Define_default_action_as_method_i__
      end
      DSL = -> _ do
        extend DSL_Meths ; nil
      end
      DSL_methods = -> _ do
        include DSL_Meths ; nil
      end
      Expressive_agent = -> x_a do
        module_exec x_a, & Headless::Action::Bundles::Expressive_agent
      end
      Inflection = -> x_a do
        module_exec x_a, & Headless::Action::Bundles::Inflection
      end
      MetaHell::Bundle::Multiset[ self ]
    end

    module DSL_Meths  # #storypoint-10
      def option_parser &p  # #storypoint-15, #storypoint-16
        (( @any_option_parser_p_a ||= [] )) << p ; nil
      end ; private :option_parser
      attr_reader :any_option_parser_p_a

      def append_syntax str  # #storypoint-20
        (( @append_syntax_a ||= [] )) << str
      end ; private :append_syntax
      attr_reader :append_syntax_a

      def desc * line_a, &p  # #storypoint-25
        if p
          line_a.length.zero? or raise ::ArgumentError, "can't have #{
            }both arguments and block"
        else
          line_a.length.zero? and raise "expecting either arguments or #{
            }block for this DSL-ish writer"
          p = -> y do
            line_a.each( & y.method( :yield ) )
          end
        end
        (( @any_description_p_a ||= [] )) << p ; nil
      end ; private :desc
      attr_reader :any_description_p_a  # :+#public-API

    private
      def default_action meth_i  # #storypoint-30
        module_exec meth_i, & Define_default_action_as_method_i__ ; nil
      end
    end

    Define_default_action_as_method_i__ = -> meth_i do
      define_method :default_action_i do meth_i end
      private :default_action_i ; nil
    end

    CEASE_X_ = false
    DASH_ = '-'.getbyte 0
    PROCEDE_X_ = true

    # ~ #orphanage

    module FUN

      Summary_width = -> op, max=0 do  # hack a peek into the o.p to
        # decide how wide to make column A (one space comes from the o.p)
        _max_d = CLI::FUN::Summary_width[ op, max ]
        _max_d + op.summary_indent.length - 1
      end
    end
  end
end
