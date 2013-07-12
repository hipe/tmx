module Skylab::Headless

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
