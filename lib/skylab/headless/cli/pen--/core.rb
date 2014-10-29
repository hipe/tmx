module Skylab::Headless

  module CLI::Pen__  # [#084]

    class << self

      def chunker
        Pen_::Chunker__
      end

      def each_pair_at * i_a, & p
        METHODS__.each_pair_at_via_arglist i_a, & p
      end

      def instance_methods_module
        Instance_Methods__
      end

      def minimal_class
        Minimal__
      end

      def minimal_instance
        MINIMAL__
      end

      def simple_style_rx
        SIMPLE_STYLE_RX__
      end

      def style_methods_module
        Style_Methods__
      end

      def stylify *a
        if a.length.zero?
          Stylify__
        else
          Stylify__[ * a ]
        end
      end

      def stylize * a
        if a.length.zero?
          Stylize__
        else
          Stylize__[ * a ]
        end
      end

      def unstyle * a
        if a.length.zero?
          Unstyle__
        else
          Unstyle__[ * a ]
        end
      end

      def unstyle_styled * a
        if a.length.zero?
          Unstyle_styled__
        else
          Unstyle_styled__[ * a ]
        end
      end
    end

    # ~

    Stylize__ = -> s, * i_a do
      Stylify__[ i_a, s ]
    end

    Stylify__ = -> style_a, str do
      "\e[#{ style_a.map { |i| CODE_H__.fetch i }.compact * ';' }m#{ str }\e[0m"
    end

    CODE_H__ = ::Hash[ [ [ :strong, 1 ], [ :reverse, 7 ] ].
        concat [ :red, :green, :yellow, :blue, :purple, :cyan, :white ].
          each.with_index.map { |v, i| [ v, i + 31 ] } ]
            # ascii-table.com/ansi-escape-sequences.php  (red = 31, etc)

    CODE_I_A__ = CODE_H__.keys.freeze

    Unstyle__ = -> s do
      Unstyle_styled__[ s ] || s
    end

    Unstyle_styled__ = -> str do
      str.dup.gsub! SIMPLE_STYLE_RX__, EMPTY_S_
    end

    SIMPLE_STYLE_RX__ = /\e  \[  \d+  (?: ; \d+ )*  m  /x

    # ~

    METHODS__ = -> do
      i_a = [] ; p_a = []
      o = -> i, p do
        i_a.push i ; p_a.push p
      end
      o.singleton_class.send :alias_method, :[]=, :call

      o[ :stylize ] = Stylize__

      o[ :unstyle ] = Unstyle__

      o[ :unstyle_styled ] = Unstyle_styled__

      ::Struct.new( * i_a ).new( * p_a )
    end.call

    class << METHODS__

      def each_pair_at * i_a, & p
        each_pair_at_via_arglist i_a, & p
      end

      def each_pair_at_via_arglist i_a
        if block_given?
          i_a.each do |i|
            yield i, self[ i ]
          end ; nil
        else
          enum_for :each_pair_at_via_arglist, i_a
        end
      end
    end

    # ~

    module Style_Methods__

      METHODS__.each_pair_at :stylize, :unstyle, & method( :define_method )

      if false  # #todo

      ( CODE_I_A__ - [ :strong ] ).each do |i|   # away at [#pl-013]

        define_method i do |s|
          stylize s, i
        end

        define_method i.upcase do |s|
          stylize s, :strong, i
        end
      end

      end
    end

    module Instance_Methods__

      include Headless_::Pen::InstanceMethods   # (see)

      # the below methods follow [#fa-052]-#the-semantic-markup-guidelines

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

      METHODS__.each_pair_at :stylize, & method( :define_method )

    end

    class Minimal__
      include Instance_Methods__
    end

    MINIMAL__ = Minimal__.new

    Pen_ = self

  end
end
