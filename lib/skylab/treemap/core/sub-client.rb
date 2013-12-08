module Skylab::Treemap

  module Core::SubClient
  end

  module Core::SubClient::InstanceMethods

    extend MetaHell::DelegatesTo

    include Headless::SubClient::InstanceMethods  # floodgates!

  private

    def init_treemap_sub_client x
      init_headless_sub_client x ; nil
    end

    def request_client= x         # .. calls this (overriden), which:
      if x
        if x.respond_to? :call    # does a cute little experiment with setting
          @rc = x                 # r.c like this for devious reasons i won't
          @request_client = nil   # admit to at this time
        else
          @rc = nil
          @request_client = x
        end
      else
        @rc = @request_client = nil
      end
      x
    end

    def request_client            # also we override this one to conincide.
      @rc ? @rc.call : @request_client or no_request_client
    end

    def no_request_client         # special hack for nice error msgs
      fail "can't delegate #{ self.class }##{ caller_locations( 1, 1 )[ 0 ].
        base_label } up to request client #{
        }because request client is human - implement it?"
    end
                                  #      ~ pen delegators are popular ~
    delegates_to :stylus,
      :em,
      :escape_path,
      :hdr,
      :ick,
      :kbd,
      :pre,
      :val
                                   #      ~ simple delegators upwards ~

    def infostream
      puts "BING: #{ self.class }"
      request_client.send :infostream  # an adapter api action wants it!!
    end

    def param x, render_method=nil  # (used to be [#011])
      request_client.send :param, x, render_method
    end

    def stylus
      request_client.send :stylus
    end

    def api_client
      request_client.send :api_client
    end
  end

  #         ~ stowaway modules (too small to have their own files) ~

  module Core::Action  # sorry, avoiding orphan
  end

  module Core::Action::ModuleMethods

    include Headless::Action::ModuleMethods  # we use its name inference
    # Headless::Action[ self, :anchored_names ]  # #todo for integration

    def define_methods_for_emitters *stream_name_a
      stream_name_a.each do |stream_name|
        if method_defined? stream_name
          raise ::ArgumentError, "this causes big problems - #{ stream_name }"
        else
          define_method stream_name do |payload_x|
            emit stream_name, payload_x
          end
        end
      end
    end
  end

  module Core::Action::InstanceMethods

    include Headless::Action::InstanceMethods
    # Headless::Action[ self, :IMs ]  # #todo for integration

    include Core::SubClient::InstanceMethods

  end

  module Core::Event  # sorry, avoiding orphan
  end

  class Core::Event::Annotated    # abstract.
                                  # assumes an overridden `build_event`
    def self.event action_sheet, stream_name, payload_x
      new action_sheet, payload_x
    end

    attr_reader :action_sheet

    def has_metadata
      false
    end

    def initialize action_sheet
      @action_sheet = action_sheet
    end
  end

  class Core::Event::Annotated::Text < Core::Event::Annotated

    attr_reader :text

    def initialize cli_action_class, text
      super cli_action_class
      @text = text
    end
  end

  Core::Event::FACTORY = PubSub::Event::Factory::Explicit.new(
    {
             payload_line: :datapoint,
                     info: :textual,
                info_line: :datapoint,
                    error: :textual,
                     help: :datapoint
    }, {
      datapoint: PubSub::Event::Factory::Datapoint
    }
  )
end
