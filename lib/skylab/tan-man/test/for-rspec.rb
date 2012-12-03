require 'shellwords'


module Skylab::TanMan::TestSupport

  shared_context tanman: true do

    include ::Skylab::TanMan::TestSupport::Tmpdir_InstanceMethods

    def api
      TanMan::API.service
    end

    let :cli do
      spy = output
      $_spy = spy
      o = TanMan::CLI.new nil, spy.for(:paystream), spy.for(:infostream)
      if do_debug
        spy.debug!
      end
      o.program_name = 'ferp'
#     o.on_info { |x| o.infostream.puts x.touch!.message } # Similar but not
#     o.on_out  { |x| o.paystream.puts x.touch!.message }  # . same as default
#     o.on_all  { |x| o.infostream.puts(x.touch!.message) unless x.touched? }
      o
    end

    def debug!
      self.do_debug = true
    end

    def input str
      argv = Shellwords.split str
      self.result = cli.invoke argv
    end

    def lone_error response, regex
      response.should_not be_success
      response.events.length.should eql(1)
      response.events.first.message.should match(regex)
    end

    def lone_success response, regex
      response.should be_success
      response.events.length.should eql(1)
      response.events.first.message.should match(regex)
    end

    let(:output) { StreamsSpy.new }

    def output_shift_is *assertions
      output.empty? and fail 'there is no output in the stack'
      subject = output.first
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
      end
      output.shift # return subject, and change the stack only at the end
    end

    def output_shift_only_is *assertions
      res = output_shift_is(*assertions)
      output.size.should eql(0)
      res
    end

    def prepare_local_conf_dir
      prepare_submodule_tmpdir.mkdir(TanMan::API.local_conf_dirname)
    end

    attr_accessor :result

    def services_clear
      TanMan::API.service.clear # [#030]
    end
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
