require_relative '../../core'
require_relative '../../..' # skylab
require 'skylab/test-support/core' # StreamSpy

module Skylab::Headless
  module Parameter::TestSupport
    def self.extended obj
      obj.extend Parameter::TestSupport::ModuleMethods
      obj.send(:include, Parameter::TestSupport::InstanceMethods)
    end
  end
  module Parameter::TestSupport::ModuleMethods
    def defn &b
      @klass = ::Class.new.class_exec do
        extend Parameter::Definer::ModuleMethods
        include Parameter::Definer::InstanceMethods
        class_exec(&b)
      protected
        def error msg ; @_outstream.puts msg end
        def pen ; IO::Pen::MINIMAL end
        def _with_client(&b) ; instance_exec(&b) end
        self
      end
    end
    def frame &b
      klass = @klass
      let(:_frame) do
        object = klass.new
        outspy = ::Skylab::TestSupport::StreamSpy.standard
        object.instance_variable_set('@_outstream', outspy)
        out_f = -> { outspy.string.split("\n") }
        { klass: klass, object: object, out_f: out_f }
      end
      let(:klass) { _frame[:klass] }
      let(:object) { _frame[:object] }
      let(:out) { _frame[:out_f].call }
      instance_exec(&b)
    end
  end
  module Parameter::TestSupport::InstanceMethods
  end
end
