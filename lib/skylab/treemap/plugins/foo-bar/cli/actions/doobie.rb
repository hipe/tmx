module Skylab::Treemap

  class Plugins::FooBar::CLI::Actions::Doobie < Plugins::FooBar::CLI::Action

    desc "do some doobies"

    emits( * Treemap::CLI::Event::CANON_STREAMS )

    # emits :payload_line, :info, :info_line, :error, :help

  protected

    def process arg1, arg2, arg3=nil
      emit :payload_line, "CERNGRETERLERTIONS: #{ arg1 } #{ arg2 } #{ arg3 }"
      0
    end

    def build_option_parser
      op = ::OptionParser.new
      op.on '-h', '--help', 'ohai i heard you like help' do
        enqueue :help
      end
      op
    end
  end
end
