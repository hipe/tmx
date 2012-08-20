require 'skylab/headless/core'
module Skylab::TanMan
  class API::Achtung
    Headless = ::Skylab::Headless
    extend Headless::Parameter::Definer::ModuleMethods
    include Headless::Client::InstanceMethods
    include Headless::Parameter::Definer::InstanceMethods::IvarsAdapter
    include Headless::Parameter::Controller::InstanceMethods
    def self.call binding, params
      cli = binding.runtime.runtime # #until:#100
      o = cli.stdout
      e = cli.stderr
      emit_f = ->(type, msg) do
        msg = msg.message if msg.respond_to?(:message) # @todo etc
        (:payload == type ? o : e).puts(msg)
      end
      new(emit_f, cli.singletons, e).invoke(params)
    end
    def invoke params
      set!(params, self) or return
      execute
    end
    attr_reader :singletons
    attr_reader :stdout # for nerpuses that have to derpus our ferpus
  protected
    def initialize emit_f, sing, errstream
      @singletons = sing
      @stdout = errstream # see 'sucky' in this submodule
      # sorry this is so convoluted, this is a jawbreaking gap bridger
      @request_runtime = request_runtime_class.new(
        nil, nil, nil,
        API::Achtung::My_IO_Adapter.new(emit_f,
                                        Headless::CLI::IO::Pen::MINIMAL)
      )
    end
    def config ; @config ||= Models::Config::Controller.new(self) end
    def error(msg)
      emit(:error, msg)
      self.errors_count += 1
      false
    end
    def errors_count ; @errors_count ||= 0 ; end
    attr_writer :errors_count
    def formal_parameters ; self.class.parameters end
  end

  module API::Achtung::InstanceMethods
  protected
    def info(m) ; emit(:info, m) ; true end
  end

  class API::Achtung
    include API::Achtung::InstanceMethods
  end

  class API::Achtung::My_IO_Adapter < ::Struct.new(:emit_f, :pen)
    Headless = ::Skylab::Headless
    def emit(type, data) ; emit_f.call(type, data) end
  end
end
