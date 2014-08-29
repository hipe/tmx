module Skylab::Brazen

  class CLI

    class Expression_Agent__

      class << self

        def pretty_path x
          self::Pretty_Path__.new( x ).execute
        end
      end

      def initialize partitions
        @partitions = partitions
      end

      attr_writer :current_property

      alias_method :calculate, :instance_exec

      def s x
        x.respond_to?( :length ) and x = x.length
        's' if 1 != x
      end

      GREEN__ = 32
      STRONG__ = 1

      def code string
        "'#{ stylize CODE_STYLE__, string }'"
      end
      CODE_STYLE__ = [ GREEN__ ].freeze

      def hdr string
        stylize HIGHLIGHT_STYLE__, "#{ string }:"
      end

      def highlight string
        stylize HIGHLIGHT_STYLE__, string
      end
      HIGHLIGHT_STYLE__ = [ STRONG__, GREEN__ ].freeze

      def ick s
        code s
      end

      def par prop
        _unstyled = send @partitions.rendering_method_name_for( prop ), prop
        highlight _unstyled
      end

      def property_default
        @current_property.default
      end

      def render_prop_as_option prop
        "--#{ prop.name.as_slug }"
      end

      def render_prop_as_argument prop
        "<#{ prop.name.as_slug }>"
      end

      def render_prop_as_environment_variable prop
        prop.environment_name_i
      end

      def pth s
        if s.respond_to? :to_path
          s = s.to_path
        end
        if DIR_SEP__ == s.getbyte( 0 )
          self.class::Pretty_Path__.new( s ).execute
        else
          s
        end
      end
      DIR_SEP__ = '/'.getbyte 0

      def val s
        s.inspect
      end

      def stylize style_d_a, string
        "\e[#{ style_d_a.map( & :to_s ).join( ';' ) }m#{ string }\e[0m"
      end
    end
  end
end
