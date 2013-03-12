module Skylab::Treemap

  class Plugins::R::Bridge

    extend PubSub::Emitter

    emits :info, :error

    event_factory PubSub::Event::Factory::Datapoint

    def activate
      begin
        if @is_active
          info "already active"
          break
        end
        @executable_path = system.which @executable_name
        if @executable_path
          @is_active = true
        else
          error "executable by this name is not in #{
            }the PATH: \"#{ @executable_name }\""
        end
      end while nil
      @is_active
    end

    attr_reader :executable_path               # concomitant with `is_ready`

    attr_reader :is_active

  protected

    def initialize &wire
      @executable_name = 'R'
      @executable_path = nil # this is really all this does now is set this
      @is_active = nil
      wire[ self ]
      nil
    end

    include Headless::System::InstanceMethods # `system.which`

    def error msg
      emit :error, msg
      @is_ready = false
    end

    def info msg
      emit :info, msg
      nil
    end
  end
end
