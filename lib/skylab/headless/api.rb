module Skylab::Headless
  module API
    # fail "this whole this will be shut down and build back up again for [#010]"
  end
  module API::InstanceMethods
    include Headless::Client::InstanceMethods
    def invoke meth, params_h=nil
      API::Promise.new do
        response do
          if ! valid_action_names.include?(meth)
            error("cannot #{meth}")
          elsif result = send(meth, *[params_h].compact)
            true == result or emit(:payload, result)
          end
        end
      end
    end
  protected
    def build_runtime_error
      runtime_error_class.new(request_runtime.io_adapter.errors.join('; '))
    end
    def response
      yield # caller must handle return value processing of client method
      if (io = request_runtime.io_adapter).errors.empty?
        io.payloads.length > 1 ? io.payloads : io.payloads.first # look
      else
        raise build_runtime_error
      end
    end
    def runtime_error_class ; API::RuntimeError end
  end

  class API::Promise < ::BasicObject # thanks Ben Lavender
    NOT_SET = ::Object.new
    def initialize &b
      @block = b
      @result = NOT_SET
    end
    def method_missing *a, &b
      __result__.send(*a, &b)
    end
    def __result__
      NOT_SET == @result and @result = @block.call
      @result
    end
  end

  class API::RuntimeError < ::RuntimeError ; end

  module API::IO end
  module API::IO::Pen end
  module API::IO::Pen::InstanceMethods
    include Headless::IO::Pen::InstanceMethods
    def em s ; "\"#{s}\"" end
    def parameter_label m, idx
      s = (::Symbol === m) ? m.to_s : m.name.inspect
      idx ? "#{s}[#{idx}]" : s
    end
  end
end
