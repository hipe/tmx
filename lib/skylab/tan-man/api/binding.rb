module Skylab::TanMan
  class API::Binding
    extend Bleeding::DelegatesTo
    include API::InvocationMethods

    delegates_to :runtime, :config, :emit, :error
    def initialize runtime, opts=nil
      @config = nil
      @runtime = runtime
      opts and opts.each { |k, v| send("#{k}=", v) }
    end
    def infostream ; runtime.infostream end
    def invalid msg
      raise API::RuntimeError.new msg
    end
    delegates_to :runtime, :program_name
    delegates_to :runtime, :root_runtime
    attr_reader :runtime
    delegates_to :root_runtime, :singletons
    delegates_to :root_runtime, :services_runtime
    delegates_to :runtime, :text_styler
  end
end

