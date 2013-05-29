module Skylab::BeautySalon

  class CLI::Client < Face::CLI

    def initialize( * )
      super
      @param_h = { }
    end

    use :api, :hi, [ :last_hot, :as, :command ],
      [ :normal_last_invocation_string, :as, :last_invocation_string ]

    with_dsl_off do
      def invoke( * )
        res = super
        if false == res
          @y << "try #{ hi "#{ last_invocation_string  } -h" } for help."
          res = nil
        end
        res
      end         # (reminder: this won't run when it's under tmx)
    end

    option_parser do |o|

      o.separator "#{ hi 'description:' }"

      o.separator <<-HERE.gsub( /^ {6}/, '' )
        outputs to stdout (unless stated otherwise) the selected lines
        after having applied the hacky wrap filter to it (effectively re-
        breaking the lines so they are flush-left ragged right, and all
        with a width less than or equal to some indicated positive non-zero
        integer.

        NOTE a) this is just an exploratory hack, "we are doing it wrong",
        and b) this is NOT intended for code, only comments or very simple
        markdown-ish.

      HERE

      o.separator "#{ hi 'options:' }"

      o.summary_width = 20

      @param_h[:do_number_the_lines] = nil
      o.on '-n', 'Number the output lines, starting at 1.',
          "(only honored in verbose preview mode for now..)" do
        @param_h[:do_number_the_lines] = true
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

      @param_h[:do_preview] = nil
      o.on '-p', '--preview', 'output only those output lines that are the',
          'result of the input lines indicated by `--lines`.',
          'all output goes to stderr.' do
        @param_h[:do_preview] = true
      end

      @param_h[:be_verbose] = nil
      o.on '-v', '--verbose', 'verbose output' do
        @param_h[:be_verbose] = true
      end

      o.banner = "#{ command.usage_line }"
    end

    def wrap file
      api file
    end

  private
  dsl_off


    def on_info e
      msg = e.payload_a.fetch 0
      if '(' == msg[ 0 ]
        a, b = '(', ')' ; msg = msg[ 1 .. -2 ]
      end
      y = @last_hot.get_normal_invocation_string_parts
      @y << "#{ a }#{ y * ' ' }: #{ msg }#{ b }"
      nil
    end

    def on_normalization_failure_line e
      @y << "#{ last_invocation_string }: #{ e.payload_a.fetch 0 }"
      nil
    end

    def on_info_line e
      @err.puts e.payload_a.fetch( 0 )
      nil
    end

    # hack to let children get this
    def on_modality_host_proxy_request plugin_client, f
      host_pxy = plugin_host.plugin_services.build_host_proxy plugin_client
      f[ host_pxy ]
      nil
    end

    Headless::Plugin::Host::Proxy.enhance self do  # at the end b.c..

      services [ :ostream, :ivar, :@out ],
               [ :estream, :ivar, :@err ]

    end
  end
end
