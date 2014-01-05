module Skylab::GitViz

  class CLI::Client  # read [#006] the CLI client narrative

    def initialize( * )
      @param_x_a = []
      super
      init_info_yielder
    end
  private
    def init_info_yielder
      if @infostream
        @y = ::Enumerator::Yielder.new( & @infostream.method( :puts ) )
      end ; nil
    end
  public

    extend Porcelain::Legacy::DSL

    desc 'ping'  # #storypoint-20

    option_parser do |o|
      o.on '--on-channel <i>' do |s|
        @param_x_a.push :on_channel, s
      end
    end

    def ping _  # #storypoint-30
      disptch_to_CLI_action
    end

    desc "fun ASCII-powered data vizualization on a git-versioned filetree"

    option_parser do |o|

    end

    argument_syntax '[<path>]'

    aliases 'ht'

    def hist_tree path=nil, _
      path and @param_x_a.push :pathname, ::Pathname.new( path )
      disptch_to_CLI_action
    end

  dsl_off

  private

    def disptch_to_CLI_action
      x_a = @param_x_a
      _i = @legacy_last_hot._sheet._name.local_normal
      _unbnd = CLI::Actions__.const_fetch _i
      _bound = _unbnd.new( svcs_for_CLI_action )
      _bound.invoke_with_iambic x_a
    end

    Headless::Client[ self,
      :client_services,
        :named, :svcs_for_CLI_action ]

    svcs_for_CLI_action_class
    class Svcs_For_CLI_Action
      def emit_on_channel_line i, s
        @up_p[].send :"#{ i }_line_from_CLI_action", s ; nil
      end
    end

    def payload_line_from_CLI_action s
      @paystream.puts s ; nil
    end

    def info_line_from_CLI_action s
      @infostream.puts s ; nil
    end
  end
end
# (keep this line for posterity - there was some AMAZING foolishness going
# on circa early '12 that is a good use case for why autoloader #todo)
