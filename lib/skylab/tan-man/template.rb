module ::Skylab::TanMan
  class Template < ::Struct.new(:pathname, :string)
    def call params
      template_string.gsub(::Skylab::Headless::CONSTANTS::MUSTACHE_RX) do
        param = $1.intern
        if params.key?(param)
          params[param]
        else
          _parametize param # ick for now we write it back maybe for chaining
        end
      end
    end
  protected
    def initialize props
      props.each { |k, v| send("#{k}=", v) }
    end
    def template_string
      if string then string
      elsif pathname
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

  module Template::Methods # used as both module and instance methods
    def _parametize name
      "{{#{name}}}" # super duper non-robust
    end
  end

  module Template::ModuleMethods
    include Template::Methods
    def from_pathname pathname
      new pathname: pathname
    end
    def from_string string
      new string: string
    end
    def parameter? str, param_name
      str.include? _parametize(param_name)
    end
  end

  class Template
    extend Template::ModuleMethods
    include Template::Methods
  end
end
