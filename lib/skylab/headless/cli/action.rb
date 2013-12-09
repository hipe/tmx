module Skylab::Headless

  module CLI::Action

    def self.[] mod, * x_a
      Bundles__.apply_iambic_on_client x_a, mod
    end

    module Bundles__

      MetaHell::FUN::Import_constants[
        Headless::Action::Bundles,
        %i( Anchored_names Client_services Expressive_agent Inflection ),
        self ]

      MetaHell::Bundle::Multiset[ self ]
    end
  end

  module CLI::Action::ModuleMethods

    include Headless::Action::ModuleMethods

    #         ~ option parser facility - module methods ~

    def option_parser &block      # dsl-ish that just accrues these for you.
      ( @option_parser_blocks ||= [ ] ) << block # turning it into an o.p.
      nil                         # is *your* responsibility. depends on what
    end                           # happens in your `build_option_parser` if any

    attr_reader :option_parser_blocks  # nil when none yet added.

    #         ~ argument syntax rendering - module methods ~

    def append_syntax str  # for hacky custom syntaxes that you want to document
      ( @append_syntax_a ||= [] ) << str
      nil
    end

    attr_reader :append_syntax_a

    #         ~ `desc` facility - module methods ~
    #   (see explanation in the corresponding i.m section)

    def desc *lines, &block       # `desc` - [#hl-033] dsl-ly writer.
      if lines.length.zero?
        if ! block
          raise ::ArgumentError, "this is a dsl-ish attr writer. arg expected"
        end
      elsif block
        raise ::ArgumentError, "can't have both lines and block."
      else
        block = -> y do
          lines.each(& y.method( :yield ) )
        end
      end
      ( @desc_blocks ||= [ ] ) << block
      nil
    end

    attr_reader :desc_blocks
  end
end
module ::Skylab::Headless  # #todo:during-merge
  module CLI::Action
    LEXICON_ = (( class Lexicon__
      def initialize
        @bx = Headless::Services::Basic::Box.new
        @is_collapsed = false ; @p_a = [] ; nil
      end
      def fetch_default_values_at_i_a i_a
        @is_collapsed or collapse
        i_a.map( & @bx.method( :fetch ) )
      end
      def fetch_default i, &p
        @is_collapsed or collapse
        @bx.fetch i, &p
      end
      def add &p
        @is_collapsed = false ; @p_a << p ; nil
      end
      def add_entry_with_default i, s
        @bx.add i, s.freeze ; nil
      end
    private
      def collapse
        @is_collapsed = true
        d = -1 ; len = @p_a.length ; last = len - 1  # assume..
        while d < last
          @p_a.fetch( d += 1 )[ self ]
        end
        @p_a[ 0, len ] = MetaHell::EMPTY_A_ ; nil
      end
      self
    end )).new

    LEXICON_.add do |lx|
      lx.add_entry_with_default :SHRT_HLP_SW, '-h'
      lx.add_entry_with_default :LNG_HLP_SW, '--help'
      lx.add_entry_with_default :THS_SCRN, 'this screen'
    end

    module ModuleMethods
      def any_option_parser_blocks
        option_parser_blocks
      end
    end
  end
end
