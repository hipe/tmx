module Skylab::Headless

  module API  # was [#010], [#017]

    Client = ::Module.new

    RuntimeError = ::Class.new ::RuntimeError
  end

  module API::Client::InstanceMethods

    include Headless::Client::InstanceMethods

    def initialize
      # just saying hello
      super
    end

    def invoke meth, params_h=nil
      API::Promise.new do
        response do
          if ! valid_action_names.include? meth
            error "cannot #{ meth }"
          elsif result = send( meth, *[ params_h ].compact )
            true == result or emit :payload, result
          end
        end
      end
    end

    def parameter_label x, idx=nil  # [#036] explains it all
      idx = "[#{ idx }]" if idx
      stem = if ::Symbol === x then x else
        stem = x.normalized_parameter_name  # errors please
      end
      "<#{ stem }#{ idx }>"
    end

    def response
      yield # caller must handle return value processing of client method

      if io_adapter.errors.length.zero?
        if io_adapter.payloads.length > 1
          io_adapter.payloads
        else
          io_adapter.payloads.first
        end
      else
        e = runtime_error_class.new( io_adapter.errors.join '; ' )
        raise e
      end
    end

    def runtime_error_class
      API::RuntimeError
    end
  end

  class API::Promise < ::BasicObject # thanks Ben Lavender

  private

    NOT_SET = ::Object.new

    def initialize &b
      @block = b
      @result = NOT_SET
    end

    def method_missing *a, &b
      __result__.send( *a, &b )
    end

    def __result__
      NOT_SET == @result and @result = @block.call
      @result
    end
  end

  module API::Pen
    # pure namespace contained entirely within this file. manifesto at H_L::Pen
  end

  module API::Pen::InstanceMethods
    include Headless::Pen::InstanceMethods

    def em s
      "\"#{ s }\""
    end
  end

  class API::Pen::Minimal
    include API::Pen::InstanceMethods
  end

  API::Pen::MINIMAL = API::Pen::Minimal.new

end
