module Skylab::Treemap

  class CLI::Option::Documenter < ::OptionParser # [#036] - - rename to ..
    include Treemap::Core::SubClient::InstanceMethods


    attr_writer :cli_action       # this is the core of the hack.
                                  # have a context when o.p renders itself.

                                  # use [#po-015] custom o.p interface
    def summarize &line
      line[ "#{ banner }" ]       # e.g "options:"
      @cli_action or fail 'sanity - cli_action'

                                  # yes, every time summarize is called,
                                  # (but think about how often that is)
                                  # we check if we need to mutate the nerks

      visit :each_option do |opt|
        if opt.respond_to?( :summarize ) && ! opt.respond_to?( :dummarize )
          opt.extend SwitchDummarize
          opt.cli_action = @cli_action
        end
      end
                                  # (we shamelessly lift parts from o.p
                                  # to make this work)
      indent = @summary_indent
      width = @summary_width
      sdone = { } ; ldone = { }
      max = width - 1

      @stack.reverse_each do |el|
        el.extend( ListDummarize ) if ! el.respond_to? :dummarize
        el.dummarize sdone, ldone, width, max, indent, &line
      end

      nil
    end

  protected

    def initialize x=nil
      super()  # important - initialze o.p!
      _treemap_sub_client_init x
      @cli_action = nil
    end

    def api_action
      @cli_action.send :api_action  # experimental access
    end
                                  # [#037] - kill this with fire, i mean no.
                                  # you are the documentor.  you are in
                                  # an option_syntax block, and an
                                  # option wants to retrieve its more
    def more name                 # lines. prepare to hack
      arr = [ ]
      yielder = ::Enumerator::Yielder.new { |line| arr << line }
      @cli_action.option_syntax.fetch_more( name ).each do |more|
        instance_exec yielder, &more
      end
      arr
    end

    def request_client            # this is how sub-client works, which lets
      @cli_action                 # you have all the nice, modality aware
    end                           # formatters like s() and and_ etc
  end

  module ListDummarize
    def self.extended list
      raise ::ArgumentError.new( 'hack failed' ) if
        !( ::OptionParser::List === list )
    end

    # copied and modified from OptionParser::List#summarize to be "streaming"
    # and filtering
    def dummarize(*a, &b)
      list.each do |opt|
        if opt.respond_to? :summarize # usu. OptionParser::Switch
          opt.dummarize( *a, &b ) # this should be hacked by now
        elsif ! opt || opt.empty?
          b[ '' ]
        elsif opt.respond_to? :each_line # e.g. Strings
          opt.each_line( &b )
        else
          opt.each( &b )
        end
      end
      nil
    end
  end

  module SwitchDummarize
    def self.extended opt
      raise 'hack failed' if ! ( ::OptionParser::Switch === opt )
      class << opt
        alias_method :treemap_original_desc, :desc
      end
      opt.extend SwitchDummarize::InstanceMethods
    end
  end

                                  # **this is an adapter for 3rc pty nerks**
                                  # moslty rendering logic, e.g.
                                  # for '{{default}} and so on
  module SwitchDummarize::InstanceMethods

    attr_writer :cli_action

    def dummarize *a, &b          # we just wrap summarize with a different
      summarize( *a, &b )         # name to catch errors early if the hack
    end                           # [#038] - saying "dumarize" is so ugly)

  protected

    attr_reader :cli_action

    mustache_rx = Headless::CONSTANTS::MUSTACHE_RX

    define_method :desc do                     # filter the o.p original thru:
      treemap_original_desc.reduce [] do |res_a, line|
        use_line = line.gsub mustache_rx do
          meth = "render_#{ $~[1] }"           # e.g. `render_default`
          if respond_to? meth
            s = send meth
          else                                 # put the orig. string back,
            s = $~[0]                          # e.g. '{{default}}' (for 2
          end                                  # reasons - chaining, loud errs)
          s
        end
        res_a << use_line
        res_a
      end
    end

    def render_default
      sw = cli_action.option_syntax.options.fetch_by_switch(
        long.first || short.first ) # shouldn't matter which, either should do
      cli_action.instance_exec do # inspired by [#sg-029] ..
        "#{ value sw.default }"
      end
    end
  end
end
