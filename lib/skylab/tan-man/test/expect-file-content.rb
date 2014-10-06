module Skylab::TanMan::TestSupport

  shared_context tanman: true do

    def input str
      argv = TestLib_::Shellwords[].split str
      self.result = cli.invoke argv
    end

    def output_shift_is *assertions
      output.lines.empty? and fail 'there is no output in the stack'
      subject = output.lines.first
      assertions.each do |assertion|
        case assertion
        when ::FalseClass ; result.should_not be_trueish
        when ::Regexp     ; subject.string.should match(assertion)
        when ::String     ; rx = /#{ ::Regexp.escape assertion }/
                          ; subject.string.should match(rx) # better error msg
        when ::Symbol     ; subject.stream_name.should eql(assertion)
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
