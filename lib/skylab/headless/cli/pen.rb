module Skylab::Headless

  module CLI::Pen

    # the pen node - stylizing facilities and default styling behavior.
    # see manifesto at H_L::Pen.

    #                   ~ ansi escape sequences ~

    code_h = ::Hash[ [ [ :strong, 1 ], [ :reverse, 7 ] ].
      concat [ :red, :green, :yellow, :blue, :purple, :cyan, :white ].
        each.with_index.map { |v, i| [ v, i + 31 ] } ]
          # ascii-table.com/ansi-escape-sequences.php  (red = 31, etc)

    o = { }

    o[:code_names] = code_h.keys

    o[:stylize] = -> str, * style_a do
      "\e[#{ style_a.map { |s| code_h[s] }.compact * ';' }m#{ str }\e[0m"
    end

    simple_style_rx = o[:simple_style_rx] = /\e  \[  \d+  (?: ; \d+ )*  m  /x

    unstylize_stylized = o[:unstylize_stylized] = -> str do # nil when `str`
      str.to_s.dup.gsub! simple_style_rx, ''   # is not already stylized
    end

    o[:unstylize] = -> str do                  # the safer alternative, for when
      unstylize_stylized[ str ] || str         # you don't care whether it was
    end                                        # stylzed in the first place

    # (see also CLI::FUN - there is extended support for e.g turning styled
    # text back and forth into s-expressions)

    FUN = ::Struct.new( * o.keys ).new( * o.values ).freeze

    Define_stylize_methods_ = -> do

      define_method :stylize, & FUN.stylize

      define_method :unstylize, & FUN.unstylize

      define_method :unstylize_stylized, & FUN.unstylize_stylized

    end

    module Methods  # API-public access to what amounts to instance-method-
      # versions of a subset of the FUN functions - if for e.g. you want
      # `stylize` or `unstylize` and you don't want to pollute your namespace
      # or coupling with all of the view-y-style names of Pen::I_M. note,
      # however, that this is still low-level: avoid calling `stylize` in
      # application code when you can instead use existing, modality-portable
      # styles.

      module_exec( & Define_stylize_methods_ )

      ( FUN.code_names - [:strong] ).each do |c|   # away at [#pl-013]
        define_method c do |s| stylize s, c end
        define_method c.to_s.upcase do |s| stylize s, :strong, c end
      end
    end

    module InstanceMethods

      include Headless::Pen::InstanceMethods   # (see)

      def em s                                 # style a header
        stylize s, :strong, :green             # (`hdr` may delegate to this)
      end

      def h2 s                                 # style a smaller header
        stylize s, :green
      end

      def ick mixed                            # style an invalid value
        %|"#{ mixed }"|
      end

      def kbd s                                # style as e.g kbd input
        stylize s, :green                      # or code
      end

      def omg x                                # style an error with
        x = x.to_s                             #  excessive & exuberant emphasis
        x = x.inspect unless x.index ' '       # (opposite human_escape)
        stylize x, :strong, :red               # may be overkill
      end

      # def `val` - how may votes? (1: sg) [#hl-051]

      module_exec( & Define_stylize_methods_ )

    end

    class Minimal
      include InstanceMethods
    end

    MINIMAL = Minimal.new

  end
end
