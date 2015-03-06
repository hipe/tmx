module Skylab::TestSupport

  class CLI


    class Expression_Agent

      # a reconception of the pen. imagine accessibility and text to speech.
      # we have hopes for this to flourish upwards and outwards.
      # think of it as a proxy for that subset of your modality client that
      # does rendering. you then pass that proxy to the snitch, which is
      # passed throughout the application and is the central conduit though
      # which all expression is received and then articulated.

      LIB_ = TestSupport_::API.lib_

      LIB_.EN_add_methods self, :private, [ :and_, :or_, :s ]

      def initialize _CLI_partitions
        @current_property = nil
        @up = _CLI_partitions
      end

      # ~ hook-outs for [br]

      alias_method :calculate, :instance_exec

      attr_writer :current_property

      # ~

      def code x
        LIB_.CLI_lib.pen.stylize x, :green
      end

      def escape_path pn
        LIB_.pretty_path_proc[ pn ]
      end

      def highlight s # [br]
        LIB_.CLI_lib.pen.stylize s, :green
      end

      def hdr s  # [br]
        LIB_.CLI_lib.pen.stylize s, :strong, :green
      end

      def ick x
        LIB_.ick x
      end

      def lbl x
        x
      end

      def par prp
        send @up.rendering_method_name_for_property( prp ), prp
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
