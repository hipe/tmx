module Skylab::TanMan::TestSupport

  shared_context tanman: true do

    include ::Skylab::TanMan::TestSupport::Tmpdir::InstanceMethods

    let :api do
      api = TanMan::Services.services.api
      if do_debug
        TanMan::API.debug = $stderr
      end
      api
    end

    let :cli do
      spy = output
      spy.line_filter! -> s do
        Headless::CLI::Pen::FUN.unstylize[ s ]
      end
      o = TanMan::CLI.new nil, spy.for(:paystream), spy.for(:infostream)
      if do_debug
        spy.debug! $stderr
      end
      o.program_name = 'ferp'
      o
    end

    def input str
      argv = TanMan::TestSupport::Services::Shellwords.split str
      self.result = cli.invoke argv
    end

    let(:output) { TestSupport::StreamSpy::Group.new }

    def output_shift_is *assertions
      output.lines.empty? and fail 'there is no output in the stack'
      subject = output.lines.first
      assertions.each do |assertion|
        case assertion
        when ::FalseClass ; result.should_not be_trueish
        when ::Regexp     ; subject.string.should match(assertion)
        when ::String     ; rx = /#{ ::Regexp.escape assertion }/
                          ; subject.string.should match(rx) # better error msg
        when ::Symbol     ; subject.name.should eql(assertion)
        when ::TrueClass  ; result.should be_trueish
        else            ; fail("unrecognized assertion class: #{assertion}")
        end
      end                         # result in subject, and change the stack
      output.lines.shift          # only at the end
    end

    def output_shift_only_is *assertions
      res = output_shift_is(*assertions)
      output.lines.length.should eql(0)
      res
    end
    attr_accessor :result
  end
end


RSpec::Matchers.define :be_trueish do
  match do |actual|
    actual
  end
end


RSpec::Matchers.define :be_gte do |expected|
  match do |actual|
    actual >= expected
  end
end
