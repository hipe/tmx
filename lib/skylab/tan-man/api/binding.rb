module Skylab::TanMan

  module Api::Actions
  end

  require File.expand_path('../action', __FILE__)

  module Api::InvocationMethods
    def invoke action=nil, args=nil
      if args.nil? && Hash === action
        args = action
        action = nil
      end
      action ||= runtime.on_no_action_name
      parts = (Array === action ? action : [action]).map do |part|
        part = part.to_s
        /\A[-a-z]+\z/ =~ part or return invalid("invalid action name part: #{part}")
        part
      end
      path = ROOT.join('api/actions', *parts[0..-2], "#{parts.last}.rb")
      path.exist? or return invalid("not an action: #{parts.join('/')}")
      require path.to_s
      const = parts.reduce(Api::Actions) do |mod, name|
        mod.const_get name.to_s.gsub(/(?:^|-)([a-z])/){ $1.upcase }
      end
      const.call(self, args)
    end
    def set_transaction_attributes transaction, attributes
      attributes or return true
      transaction.update_attributes!(attributes)
    end
  end

  class Api::Binding
    extend Bleeding::DelegatesTo
    include Api::InvocationMethods

    delegates_to :runtime, :config, :emit, :error
    def initialize runtime, opts=nil
      @config = nil
      @runtime = runtime
      opts and opts.each { |k, v| send("#{k}=", v) }
    end
    def invalid msg
      raise RuntimeError.new(msg)
    end
    delegates_to :runtime, :program_name
    delegates_to :runtime, :root_runtime
    attr_reader :runtime
    delegates_to :root_runtime, :singletons
    delegates_to :runtime, :stdout, :text_styler
  end
end

