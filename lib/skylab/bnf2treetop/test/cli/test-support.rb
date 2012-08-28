load File.expand_path('../../../../../../bin/bnf2treetop', __FILE__)

require_relative('../../..')

require 'skylab/test-support/core'
require 'skylab/headless/core' # unstylize

module Skylab::Bnf2Treetop::TestSupport
  Bnf2Treetop = ::Skylab::Bnf2Treetop
  module CLI
    def self.extended mod
      mod.module_eval do
        extend CLI::ModuleMethods
        include CLI::InstanceMethods
      end
    end
  end
  module CLI::ModuleMethods
    def invoke *argv, &output_f
      ::Hash === argv.last and tags = argv.pop # BE CAREFUL!!!!
      let(:_frame) do
        errstream = ::Skylab::TestSupport::StreamSpy.standard
        outstream = ::Skylab::TestSupport::StreamSpy.standard
        cli = Bnf2Treetop::CLI.new(outstream, errstream)
        cli.program_name = 'bnf2treetop'
        o = ::Struct.new(:debug_f, :err_f, :out_f).new # 'joystick'
        o.debug_f = ->{ outstream.debug!; errstream.debug! }
        collapsed_f = -> do
          oo = ::Struct.new(:err, :out, :result).new
          oo.result = cli.invoke argv
          oo.out = outstream.string.split("\n")
          oo.err = errstream.string.split("\n")
          (collapsed_f = ->{ oo }).call
        end
        o.err_f = ->{ collapsed_f.call.err }
        o.out_f = ->{ collapsed_f.call.out }
        o
      end
      output_f and make_an_example_out_of(output_f, * [tags].compact)
    end
    def make_an_example_out_of output_f, *a
      o = ::BasicObject.new
      labels = []
      class << o ; self end.send(:define_method, :method_missing) do |m, *a|
        labels.push "#{m.to_s.gsub('_', ' ')}#{'(..)' unless a.empty?}"
      end
      o.instance_eval(&output_f)
      labels.empty? and labels.push('(none)') # sanity
      it "outputs #{labels.join(', ')}", *a do
        instance_eval(&output_f)
      end
    end
  end
  module CLI::InstanceMethods
    include ::Skylab::Headless::CLI::IO::Pen::InstanceMethods

    FIXTURES = ::Pathname.new(File.expand_path('../../fixtures', __FILE__))

    def debug! ; _frame.debug_f.call end
    def err    ; _frame.err_f.call   end
    def out    ; _frame.out_f.call   end
  end
end
