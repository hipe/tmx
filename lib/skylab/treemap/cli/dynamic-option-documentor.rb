module Skylab::Treemap
  class CLI::DynamicOptionDocumentor < ::OptionParser
    extend DelegatesTo

    attr_accessor :cli

    def documentor?
      true
    end

    def help &line
      line.call("#{banner}")
      sdone = {} ; ldone = {} ; width = @summary_width ; max = width - 1 ; indent = @summary_indent

      visit(:each_option) do |opt|
        if opt.respond_to?(:summarize) and ! opt.respond_to?(:dummarize)
          opt.extend SwitchDummarize
          opt.cli = cli
        end
      end

      @stack.reverse_each do |el|
        el.respond_to?(:dummarize) or el.extend(ListDummarize)
        el.dummarize(sdone, ldone, width, max, indent, &line)
      end

      nil
    end

    delegates_to :cli, :option_syntax

    def more name
      instance_exec(&option_syntax.more[name])
    end

    delegates_to :cli, :stylus
    delegates_to :stylus, :and, :hdr, :or, :pre, :param, :s
  end

  module ListDummarize
    def self.extended list
      list.kind_of?(OptionParser::List) or raise('hack failed')
    end
    # copied and modified from OptionParser::List#summarize to be "streaming"
    # and filtering
    def dummarize(*a, &b)
      list.each do |opt|
        if opt.respond_to?(:summarize) # usu. OptionParser::Switch
          opt.dummarize(*a, &b) # this should be hacked by now
        elsif !opt or opt.empty?
          b.call ''
        elsif opt.respond_to?(:each_line) # e.g. Strings
          opt.each_line(&b)
        else
          opt.each(&b)
        end
      end
      nil
    end
  end
  module SwitchDummarize
    def self.extended opt
      opt.kind_of?(::OptionParser::Switch) or raise('hack failed')
      opt.singleton_class.send(:alias_method, :orig_desc, :desc)
      opt.extend SwitchDummarize::InstanceMethods
    end
  end
  module SwitchDummarize::InstanceMethods
    attr_accessor :cli
    def desc
      orig_desc.map do |line|
        line.gsub(::Skylab::Headless::CONSTANTS::MUSTACHE_RX) do
          name = $1
          if respond_to?("render_#{name}")
            send("render_#{name}")
          else
            '' # or whatever
          end
        end
      end
    end
    def dummarize(*a, &b)
      summarize(*a, &b)
    end
    def render_default
      cli.stylus.value cli.option_syntax.options.by_switch[long.first || short.first].default
    end
  end
end

