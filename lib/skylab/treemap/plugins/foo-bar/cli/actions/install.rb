module Skylab::Treemap
  class Plugins::FooBar::CLI::Actions::Install < Plugins::FooBar::CLI::Action

    desc "yerp"

  protected

    def build_option_parser
      ::OptionParser.new do |op|
        op.on '-h', '--help', 'this screen.' do enqueue :help end
      end
    end

    def process
      emit :info, "this is me (foo) yerping."
      0
    end
  end
end
