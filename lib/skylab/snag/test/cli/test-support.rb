require_relative '../test-support'

module Skylab::Snag::TestSupport::CLI
  ::Skylab::Snag::TestSupport[ CLI_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie  # try running a _spec.rb file with `ruby -w`


  module InstanceMethods
    include CONSTANTS

    let :client do
      output = self.output
      client = Snag::CLI.new nil, output.for( :pay ), output.for( :info )
      client.program_name = 'issue'
      client
    end

    def client_invoke *argv
      output.lines.clear
      @result = client.invoke argv
    end

    def o *a
      if a.empty?
        output.lines.length.should eql(0)
      else
        if 1 == a.length
          a.unshift :info
        end
        if 2 != a.length
          fail "sanity - expecting [type] [rx], had #{ a.inspect }"
        end
        name, rx = a
        curr = output.lines.shift
        if curr
          curr.string.should match( rx )
          curr.name.should eql(name)
        else
          fail "Had no more events in queue, expecting #{ [type, rx].inspect }"
        end
      end
      nil
    end

    let :output do
      output = TestSupport::StreamSpy::Group.new
      output.line_filter! -> s do
        Headless::CLI::Pen::FUN.unstylize[ s ]
      end
      output.debug = -> { debug? }
      output
    end

    attr_reader :result
  end
end
