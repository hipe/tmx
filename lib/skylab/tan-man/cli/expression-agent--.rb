module Skylab::TanMan

  class CLI

    class Expression_Agent__

      def initialize partitions
        @kernel = partitions.kernel.application_kernel
      end

      attr_writer :current_property

      alias_method :calculate, :instance_exec

      def app_name
        @kernel.app_name
      end

      def property_value i
        @kernel.kernel_property_value i
      end

      def invoke_notify
        TanMan_::Lib_::Old_path_tools[].clear
      end

    private

      # follows [#fa-052]:#the-semantic-markup-guidelines

      green = 32 ; strong = 1

      def and_ a
        a * ' and '  # #todo
      end

      def code s
        kbd "'#{ s }'"
      end

    public def hdr x
        stylize HEADER_STYLE__, "#{ x }:"
      end
      HEADER_STYLE__ = [ strong, green ].freeze

      def highlight string
        "** #{ string } **"
      end

      def ick x
        "\"#{ x }\""
      end

      def indefinite_noun * a
        _NLP_agent.indefinite_noun.via_arglist a
      end

      def kbd s
        stylize KEYBOARD_STYLE__, s
      end
      KEYBOARD_STYLE__ = [ green ].freeze

      def lbl x  # render a business parameter name
        kbd x
      end

      def par prop  # [#sl-036] - super hacked for now
        kbd "<#{ prop.name.as_slug.gsub '_', '-' }>"
      end

      def plural_noun * a
        _NLP_agent.plural_noun.via_arglist a
      end

      def pth path_x
        FUN__.pretty_path[ path_x ]
      end

      def s *a  # #todo
        if a.last.respond_to? :id2name then a.last
        elsif a[ 0 ].respond_to? :upto
          's' if 1 != a[ 0 ]
        end
      end

      def val x
        x
      end

      def stylize style_d_a, string
        "\e[#{ style_d_a.map( & :to_s ).join( ';' ) }m#{ string }\e[0m"
      end

      def _NLP_agent
        @NLP_agent ||= TanMan_::API.expression_agent_class.NLP_agent.new
      end
    end
  end
end
