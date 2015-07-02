module Skylab::Headless

  module CLI::Pen__

    # (the "meat" of this file moved to [#br-092]. what is left is sunsetting..)

    class << self

      def instance_methods_module
        Instance_Methods__
      end

      def minimal_class
        Minimal__
      end

      def minimal_instance
        MINIMAL__
      end
    end

    module Instance_Methods__

      include Home_::Pen::InstanceMethods   # (see)

      # the below methods follow [#br-093]-#the-semantic-markup-guidelines

      def em s
        stylize s, :strong, :green
      end

      def h2 s
        stylize s, :green
      end

      def ick mixed
        %|"#{ mixed }"|
      end

      def kbd s
        stylize s, :green
      end

      def omg x
        x = x.to_s
        x = x.inspect unless x.index TERM_SEPARATOR_STRING_
        stylize x, :strong, :red
      end

      def par x
        _slug = if x.respond_to? :name
          x.name.as_slug
        else
          x.id2name.gsub UNDERSCORE_, DASH_
        end
        kbd "<#{ _slug }>"
      end

      def param i
        i
      end

      def pth x
        x.respond_to? :to_path and x = x.to_path
        "«#{ ::File.basename "#{ x }" }»"  # :+#guillemets
      end

      # def `val` - how may votes? (1: sg) [#051]

      Home_.lib_.brazen::CLI::Styling.each_pair_at(
        :stylize,
        & method( :define_method ) )
    end

    class Minimal__
      include Instance_Methods__
    end

    MINIMAL__ = Minimal__.new

    Pen_ = self

  end
end
