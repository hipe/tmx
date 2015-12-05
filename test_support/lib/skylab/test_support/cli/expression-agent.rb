module Skylab::TestSupport

  module CLI

    class Expression_Agent

      # a reconception of the pen. imagine accessibility and text to speech.
      # we have hopes for this to flourish upwards and outwards.
      # think of it as a proxy for that subset of your modality client that
      # does rendering. you then pass that proxy to the snitch, which is
      # passed throughout the application and is the central conduit though
      # which all expression is received and then articulated.

      LIB_.human::NLP::EN::Methods.call self, :private, [ :and_, :or_, :s ]

      def initialize _CLI_partitions
        @current_property = nil
        @up = _CLI_partitions
      end

      # ~ hook-outs for [br]

      alias_method :calculate, :instance_exec

      attr_writer :current_property

      # ~

      def code x
        Home_.lib_.brazen::CLI_Support::Styling.stylize x, :green
      end

      def escape_path path_x
        Home_.lib_.system.filesystem.path_tools.pretty_path path_x
      end

      def highlight s # [br]
        Home_.lib_.brazen::CLI_Support::Styling.stylize s, :green
      end

      def hdr s  # [br]
        Home_.lib_.brazen::CLI_Support::Styling.stylize s, :strong, :green
      end

      def ick x
        LIB_.basic::String.via_mixed x
      end

      def lbl x
        x
      end

      def par prp
        send @up.expression_strategy_for_property( prp ), prp
      end

      # ~ (from above)

      def render_property_as__argument__ prp
        "<#{ prp.name.as_slug }>"
      end

      # ~
      def val x
        @client.hi x
      end
    end
  end
end
