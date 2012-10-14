require 'skylab/headless/core'

module ::Skylab::TanMan
  class Template < ::Struct.new(:pathname)
    def call params
      template_string.gsub(::Skylab::Headless::Constants::MUSTACHE_RX) do
        param = $1.intern
        if params.key?(param)
          params[param]
        else
          "{{#{param}}}" # ick for now we write it back maybe for chaining
        end
      end
    end
  protected
    def initialize props
      props.each { |k, v| send("#{k}=", v) }
    end
    def template_string
      if pathname
        if pathname.exist?
          pathname.read
        else
          fail "template file not found: #{pathname}"
        end
      else
        fail "template has no template string."
      end
    end
  end
end
