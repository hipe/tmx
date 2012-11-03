require 'skylab/headless/core'
module Skylab::TanMan
  # Literate programming, for once!?

  module API::Achtung
    # The idea of 'Achtung' is that it is a surrogate stand-in until we refactor
    # out the old porcelain actions (#018).  But the new headless way is not yet
    # developed enough to do that now.  Everything under 'Achtung' should
    # be considered very experimental.
    #
    # Ideally, this wiring crap will be thin, and will be handled by
    # headless, and we can focus on our business logix
  end

  class API::Achtung::SubClient
    # used as a class and as a namespace, reopened below
  end

  module API::Achtung::SubClient::ModuleMethods

    # Using call() gives us a thick layer of isolation between the outward
    # representation and inward implementation of an action.  Outwardly,
    # actions are represented merely as constants inside of some Module
    # that, all we know is, these constants respond to call().  Inwardly,
    # they might be just lambdas, or they might be something more.  This
    # pattern may or may not stick around, and is part of #100.

    def call binding, params
      # During #before:#100 times, we make the request runtime here.
        # Whatever this binding is supposed to be, it is stupid and confusing.
      # the only things passed to "call" should be a client and params
      cli_action = binding.runtime
      cli = cli_action.runtime
      runtime = headless_runtime cli_action
      action = new runtime
      action.infostream = cli.stderr
      action.singletons_f = ->{ binding.singletons }
      action.invoke(params)
    end

    def headless_runtime client
      runtime = ::Skylab::Headless::Request::Runtime::Minimal.new
      runtime[:io_adapter] = API::Achtung::IO_Adapter_Retrofitter.new(
        client,
        ::Skylab::Headless::CLI::IO::Pen::MINIMAL # #jawbreaking
      )
      runtime
    end
  end

  module API::Achtung::SubClient::InstanceMethods
    protected
    def info m
      emit :info, m
      true
    end
  end

  class API::Achtung::SubClient
    extend API::Achtung::SubClient::ModuleMethods

    # Let's see how clean we can keep this implementation here. To what extent
    # can action classes just simply be headless sub-clients?
    include ::Skylab::Headless::SubClient::InstanceMethods
    include API::Achtung::SubClient::InstanceMethods

    # Some but not necessarily all action classes will want to use the
    # parameter definer / invoke / exec pattern for their action classes
    parameter = ::Skylab::Headless::Parameter
    extend parameter::Definer::ModuleMethods
    include parameter::Definer::InstanceMethods::IvarsAdapter
    include parameter::Controller::InstanceMethods

    attr_accessor :infostream # service

    def invoke params
      set!(params, self) or return
      execute # (you might find this pattern elsewhere in headless)
    end

    # This sub=client will act as the parent runtime for model controllers,
    # and as such it must provide the below methods as a #service to those
    # model controllers. (#todo #after:#100 revisit this)
    def singletons ; singletons_f.call end

    attr_accessor :singletons_f
      # #todo: rename these. it may be a good pattern but it's a terrible name

  protected


    def config # #pattern #016
      @config ||= TanMan::Models::Config::Controller.new self
    end

    def dot_files # #pattern #016
      @dot_files ||=
        TanMan::Models::DotFiles::Controller.new request_runtime, config
    end

    def error msg # #pattern #017
      emit :error, msg
      self.errors_count += 1
      false
    end

    def errors_count # #pattern #017
      @errors_count ||= 0
    end

    attr_writer :errors_count # #pattern #017

    def formal_paramters # #pattern #017
      self.class.parameters
    end
  end

  class API::Achtung::IO_Adapter_Retrofitter < ::Struct.new :client, :pen
    def emit type, payload
      client.emit type, payload
    end
  end
end
