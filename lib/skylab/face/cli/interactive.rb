class Skylab::Face::CLI
  class Interactive
    def self.run ui, opts, request
      new(ui, opts, request).run
    end
    def initialize ui, opts, request
      @ui, @opts, @request = [ui, opts, request]
    end
    def run
      require 'highline'
      @terminal = ::HighLine.new($stdin, @ui.err)
      @params = @request.parameters
      @request.label and @terminal.say(@request.label)
      @request.description and @terminal.say(@request.description)
      begin
        @params.each do |param|
          unless ask_for(param)
            break;
          end
        end
      rescue ::Interrupt => e
        @terminal.say("\nCancelled #{@request.some_label.downcase}.")
        @request.valid = false
      end
      @request
    end
    def ask_for param
      value = @terminal.ask("#{param.label}: ")
      param.set_response(value)
    end
  end
end
