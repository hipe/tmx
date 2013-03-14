module Skylab::Snag
  # this whole file is only for during integration!
  class API::MyEvent < PubSub::Event::Unified

    def message= msg # parent class doens't provide this
      @msg = msg
    end

    def msg # it derps over on payload.to_s without this # #todo
      if @msg then
        if ::String === @msg then @msg else
          require 'debugger' ; debugger ; 1==1
        end
      else
        if ::String === @stream_name then
          @stream_name
        elsif @stream_name.respond_to? :payload_a
          @stream_name.payload_a[0]
        else
          @stream_name.to_s
        end
      end
    end

    # silly fun
    attr_accessor :inflection
    def noun
      inflection.inflected.noun
    end
    def verb
      inflection.stems.verb
    end

    def does_render_for
      @stream_name.respond_to? :render_for  # #todo integration only
    end

    def render_for x  # #todo integration only
      if ::String === @stream_name
        @stream_name
      else
        @stream_name.render_for x
      end
    end

    def initialize *a
      @msg = nil
      super
    end
  end
end
