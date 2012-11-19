require_relative '../test-support'

module Skylab::Headless::TestSupport::Parameter
  ::Skylab::Headless::TestSupport[ self ]


  module CONSTANTS
    Parameter = Headless::Parameter
  end


  module ModuleMethods
    include CONSTANTS

    def with &b                   # define the class body you will use in
      @klass = ::Class.new.class_exec do      # the frame
        include Headless::SubClient::InstanceMethods
        extend Parameter::Definer
        class_exec(&b)
      protected
        # A definition of formal_parameters is needed for compat. with
        # bound params.  currently its home definition is in
        # Parameter::Controller::InstanceMethods, however pulling all of that in
        # is out of scope here, hence we redundantly define this here, but if
        def formal_parameters     # this moves up to e.g some I_M::Core,
          self.class.parameters   # then by all means get rid of it here!
        end
        def with_client &b        # slated for improvement [#012]
          instance_exec &b
        end
        self
      end
    end

    def frame &b
      klass = @klass
      let :_frame do
        client = Headless_TestSupport::Client_Spy.new
        client.debug = -> { self.debug }
        object = klass.new client
        emit_lines = -> do
          client.send(:io_adapter).stack.map do |pair|
            pair.length == 2 or fail('sanity - unexpected payload length')
            pair.last
          end
        end
        { emit_lines: emit_lines, klass: klass, object: object }
      end
      let(:emit_lines)   { _frame[:emit_lines].call }
      let(:klass)  { _frame[:klass] }
      let(:object) { _frame[:object] }
      instance_exec(&b)
    end
  end
end
