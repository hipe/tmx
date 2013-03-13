[#058]       #doc-point narrative pre-order ("outside-in") ..
module Skylab::Face
  # @todo:#100.100.300: eliminate unused code (like this file)
  class Request
    def self.build &block
      req = new
      block.call(req)
      req
    end
    def initialize
      @parameters = []
      @label = @description = nil
    end
    attr_accessor :description
    attr_accessor :label
    attr_reader :parameters
    attr_accessor :valid
    def param &block
      param = Parameter.new
      block.call(param)
      @parameters.push param
      param
    end
    def some_label
      @label || "Request"
    end
    def valid?
      if @validation_block
        #@todo
      elsif nil != @valid
        @valid
      else
        true
      end
    end
    class Parameter
      def initialize
        @label = nil
        @value = nil
      end
      attr_accessor :label
      attr_reader :value
      def intern
        @label or return nil
        @label.downcase.gsub(/[^_a-z0-9]/, '_').intern
      end
      def set_response str
        @value = str
      end
    end
  end
end
