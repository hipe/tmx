module Skylab::BeautySalon

  class CLI < Home_.lib_.brazen::CLI

    def self.new * a
      new_top_invocation a, Home_.application_kernel_
    end

    def expression_agent_class
      Brazen_::CLI::Expression_Agent
    end

    # ~ #hook-out for [tmx] integration (this whole file)

    module Client
      Adapter = self
      For = self
      Face = self
      Of = self
      Hot = -> x, x_ do

        Home_.lib_.brazen::CLI::Client.fml Home_, x, x_
      end
    end

    if false

      o.separator <<-HERE.gsub( /^ {6}/, EMPTY_S_ )
        outputs to stdout (unless stated otherwise) the selected lines
        after having applied the hacky wrap filter to it (effectively re-
        breaking the lines so they are flush-left ragged right, and all
        with a width less than or equal to some indicated positive non-zero
        integer.

        NOTE a) this is just an exploratory hack, "we are doing it wrong",
        and b) this is NOT intended for code, only comments or very simple
        markdown-ish.

      HERE

      @param_h[ :number_the_lines ] = nil
      o.on '-n', 'Number the output lines, starting at 1.',
          "(only honored in verbose preview mode for now..)" do
        @param_h[ :number_the_lines ] = true
      end

      @param_h[:num_chars_wide] = 80
      o.on '-c', '--num-chars-wide NUM',
        "how wide can the longest line be? (default: #{
          @param_h[:num_chars_wide]  })" do |x|
        @param_h[:num_chars_wide] = x
      end

      @param_h[:lines] = nil
      o.on '-l RANGES', '--lines RANGES',
          'apply the filter only to this range of lines (e.g "-l 1-16,26-38").',
          "a range can be a single number. multiple ranges can be specified",
          "using the comma, also the `--lines` option may be employed multiple",
          "times. ranges that do not \"make sense\" will lead to an alternate",
          "early ending (error); but out of bounds ranges are silently",
          "ignored. see how overlapping ranges are processed by turning",
          "on `--verbose`." do |x|
        ( @param_h[:lines] ||= [] ) << x
      end

      @param_h[ :preview ] = nil
      o.on '-p', '--preview', 'output only those output lines that are the',
          'result of the input lines indicated by `--lines`.',
          'all output goes to stderr.' do
        @param_h[ :preview ] = true
      end

      @param_h[ :verbose ] = nil
      o.on '-v', '--verbose', 'verbose output' do
        @param_h[ :verbose ] = true
      end
    end

    if false

    class Expression_Agent___ < Brazen_::CLI.expression_agent_class

      define_method :ellipsulate__, -> do

        _A_RATHER_SHORT_LENGTH = 8

        p = -> s do
          p = Home_.lib_.basic::String.ellipsify.curry[ _A_RATHER_SHORT_LENGTH ]
          p[ s ]
        end

        -> s do
          p[ s ]
        end
      end.call
    end
    end

  end
end
