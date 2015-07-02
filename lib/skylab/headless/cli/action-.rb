module Skylab::Headless

  module CLI

    class << self  # ~ :#stowaway

      def action * a
        if a.length.zero?
          Action_
        else
          Action_.call_via_arglist a
        end
      end

      def argument * a
        if a.length.zero?
          CLI::Argument_
        else
          CLI::Argument_.new( * a )
        end
      end

      def client * a
        CLI::Client.call_via_arglist a
      end

      def option
        CLI::Option__
      end

      def pen
        CLI::Pen__
      end

      def tree
        CLI::Tree__
      end
    end  # >>
  end

  module CLI::Action_  # #storypoint-5 in [#039] the CLI action narrative

    class << self

      def [] mod, * x_a
        via_client_and_iambic mod, x_a
      end

      def desc
        Action_::Desc__
      end

      def summary_width op, max=0  # hack a peek into the o.p to
        # decide how wide to make column A (one space comes from the o.p)

        _max_d = Home_.lib_.brazen::CLI::Option_Parser.summary_width op, max
        _max_d + op.summary_indent.length - 1
      end

      def call_via_arglist a
        via_client_and_iambic a.shift, a
      end

      def via_client_and_iambic mod, x_a
        Bundles__.apply_iambic_on_client x_a, mod
      end
    end

    module Bundles__
      Actions_anchor_module = -> x_a do
        module_exec x_a, & Home_::Action::Bundles::Actions_anchor_module
      end
      Anchored_names = -> x_a do
        module_exec x_a, & Home_::Action::Bundles::Anchored_names
      end
      Client_services = -> x_a do
        module_exec x_a, & Home_::Action::Bundles::Client_services
      end
      Core_instance_methods = -> _ do
        include CLI::Action_::IMs ; nil
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
        module_exec x_a, & Home_::Action::Bundles::Expressive_agent
      end
      Inflection = -> x_a do
        module_exec x_a, & Home_::Action::Bundles::Inflection
      end
      Home_.lib_.bundle::Multiset[ self ]
    end

    module DSL_Meths  # #storypoint-10

      def option_parser_class x
        p_ = x.respond_to?( :call ) ? x : -> { x }
        define_method :option_parser_cls, p_
        private :option_parser_cls ; nil
      end ; private :option_parser_class

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
            line_a.each( & y.method( :<< ) )
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

    Action_ = self
    CEASE_X_ = false  # #storypoint-7 in [#039]
    OK_ = true
    PROCEDE_X_ = true

  end
end
