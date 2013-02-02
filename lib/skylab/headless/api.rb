module Skylab::Headless

  module API
    # fail "this whole this will be shut down and build back up again for [#010]"
    # the frontier sub-product for this is flex2treetop - make sure to
    # cross-test the two! changes anticipated near [#017]

    class API::RuntimeError < ::RuntimeError
    end
  end


  module API::InstanceMethods
    include Headless::Client::InstanceMethods

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

  protected

    def response
      yield # caller must handle return value processing of client method

      if io_adapter.errors.empty?
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

  protected

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

    def parameter_label m, idx=nil
      s = (::Symbol === m) ? m.to_s : m.normalized_local_name.inspect
      idx ? "#{ s }[#{ idx }]" : s
    end
  end


  class API::Pen::Minimal
    include API::Pen::InstanceMethods
  end


  API::Pen::MINIMAL = API::Pen::Minimal.new

end
