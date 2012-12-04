require_relative 'core'

module Skylab::MyTree

  module CLI
    def self.new *a
      block_given? and raise ::ArgumentError.exception 'no'
      CLI::Client.new(* a)
    end
  end


  class CLI::Client
    include Headless::CLI::Client::InstanceMethods
    include Headless::CLI::Box::InstanceMethods

  protected

    def box
      API::Actions
    end

    def build_option_parser # #frontier
      o = ::OptionParser.new
      # o.on '-a', '-b', '-c JAMI', '-d WANKI', 'some tesco'
      # o.on '--alabaster-platypus <FRANCIS_MACDERMOT>'
      # o.on '--wat <PEACE>', 'parla tedesco'
      o.on '-h', '--help', 'this screen, or help for particular action' do
        box_enqueue_help!
      end
      o.summary_indent = '  ' # two spaces, down from four
      # o.banner = "#{ usage_line }\n#{ em 'options:' }" # the old hack
      o
    end
  end
end
