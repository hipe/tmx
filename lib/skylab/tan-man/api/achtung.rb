require 'skylab/headless/core'
module Skylab::TanMan
  # Literate programming, for once!?

  module API::Achtung
    # The idea of 'Achtung' is that it is a surrogate stand-in until we refactor
    # out the old porcelain actions.  But the new headless way is not yet
    # developed enough to do that now.  Everything under 'Achtung' should
    # be considered very experimental.
    #
    # Ideally, this wiring crap will be thin, and will be handled by
    # headless, and we can focus on our business logix
  end

  # Isolate the runtime-building part so it can be called (ahem) elsewhere.
  # It is not made in a more flexible way b/c it's a #jawbreaker.
  API::Achtung::BUILD_RUNTIME_F = ->(outstream, errstream) do
    ::Skylab::Headless::Request::Runtime::Minimal.new(
      API::Achtung::IO_Adapter_Functional.new(
        ->(type, msg) do
          msg = msg.message if msg.respond_to?(:message) # @todo etc
          (:payload == type ? outstream : errstream).puts(msg)
        end,
        ::Skylab::Headless::CLI::IO::Pen::MINIMAL # #jawbreaking
      )
    )
  end

  class API::Achtung::SubClient ; end # used as a class and as a namespace

  module API::Achtung::SubClient::InstanceMethods

  protected
    def info(m) ; emit(:info, m) ; true end               # common pattern
  end

  class API::Achtung::SubClient
    include API::Achtung::SubClient::InstanceMethods

    # Using call() gives us a thick layer of isolation between the outward
    # representation and inward implementation of an action.  Outwardly,
    # actions are represented merely as constants inside of some Module
    # that, all we know is, these constants respond to call().  Inwardly,
    # they might be just lambdas, or they might be something more.  This
    # pattern may or may not stick around, and is part of #100.

    def self.call binding, params
      # During #before:#100 times, we make the request runtime here.
      # Experimentally, we make it as thin as possible.

      cli = binding.runtime.runtime
        # Whatever this binding is supposed to be, it is stupid and confusing.
        # binding.runtime is the CLI action object.
        # *It's runtime is the base CLI client.
        # We have to back all the way out to that
        # and then build ourselves up from it.

      errstream = cli.stderr
      outstream = cli.stdout
      action = new(API::Achtung::BUILD_RUNTIME_F.call(outstream, errstream))
      action.infostream = errstream
      action.singletons_f = ->{ binding.singletons }
      action.invoke(params)
    end

    # Let's see how clean we can keep this implementation here. To what extent
    # can action classes just simply be headless sub-clients?
    include ::Skylab::Headless::SubClient::InstanceMethods


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

    def config ; @config ||= Models::Config::Controller.new(self) end
      # action instance spawns instance of model controller #pattern

    def error msg                                         # common pattern
      emit(:error, msg)
      self.errors_count += 1
      false
    end
    def errors_count ; @errors_count ||= 0 ; end          # per param contr. api
    attr_writer :errors_count                             # per param contr. api
    def formal_parameters ; self.class.parameters end     # per param contr. api
  end

  class API::Achtung::IO_Adapter_Functional < ::Struct.new(:emit_f, :pen)
    # this will ofc. be #pushed-up if it proves useful. (but don't even
    # think about doing that until we work out the abounding #jawbreaks)

    def emit type, data
      emit_f.call type, data
    end
  end
end
