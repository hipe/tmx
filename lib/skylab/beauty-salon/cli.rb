module Skylab::BeautySalon

  module CLI  # #stowaway
    def self.new *a
      CLI::Client.new( *a )
    end
  end

  class CLI::Client < BS_.lib_.old_CLI_lib::Client

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

    set :node, :ping, :invisible

    def ping
      @y << "hello from beauty salon."
      :hello_from_beauty_salon
    end

    option_parser do |o|

      o.separator "#{ hi 'description:' }"

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

    option_parser do |o|

      @action = BS_::Models_::Deliterate.new NO_KERNEL__ do | *, & ev_p |

        ev_p[].render_all_lines_into_under @y,

          BS_.lib_.brazen::CLI.expression_agent_instance

        false
      end

      @action.write_options o

      @x_a = []

      nil
    end

    NO_KERNEL__ = class No_Kernel__
      def to_kernel
      end
      self
    end.new

    def deliterate file=nil, from_line, to_line

      x_a =  @x_a

      if file
        x_a.push :input_path, file
      else
        x_a.push :input_stream, @sin
      end

      _out_y = ::Enumerator::Yielder.new do |s|
        @out.write s
      end

      x_a.push :comment_line_yieldee, @y
      x_a.push :code_line_yieldee, _out_y
      x_a.push :from_line, from_line, :to_line, to_line

      bc = @action.bound_call_against_iambic_stream(
        Callback_::Iambic_Stream.via_array( x_a ) )

      @x_a = nil

      if bc
        bc.receiver.send( bc.method_name, * bc.args )
      else
        bc
      end
    end

    option_parser do |o|
      @client = BS_::Models_::Search_and_Replace.client_for_three @sin, @out, @err
      @client.write_options o
      nil
    end

    def search_and_replace
      @client.run
    end

  private
  dsl_off


    def on_info_string e  # meh
      msg = e.payload_a.fetch 0
      if '(' == msg[ 0 ]
        a, b = '(', ')' ; msg = msg[ 1 .. -2 ]
      end
      y = @mechanics.last_hot.get_normal_invocation_string_parts
      @y << "#{ a }#{ y * ' ' }: #{ msg }#{ b }"
      nil
    end

    def on_normalization_failure_line_notify e
      @y << "#{ @mechanics.normal_last_invocation_string }: #{
        }#{ e.payload_a.fetch 0 }"
      nil
    end

    def on_info_line e
      @err.puts e.payload_a.fetch( 0 )
      nil
    end

    BS_.lib_.plugin::Host::Proxy.enhance self do  # at the end b.c..

      services [ :ostream, :ivar, :@out ],
               [ :estream, :ivar, :@err ]

    end
  end
end
