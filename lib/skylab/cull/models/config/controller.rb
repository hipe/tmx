module Skylab::Cull

  class Models::Config::Controller

    module Events
    end

    -> do  # `new_valid`

      Init_ = ::Struct.new :api_client, :pathname
      define_singleton_method :new_valid do |init, obj_if_ok, msg_if_not_ok|
        init[ st = Init_.new ]
        -> do
          st.api_client or break msg_if_not_ok[ '`api_client` is required' ]
          st.pathname or break msg_if_not_ok[ '`pathname` is required' ]
          obj_if_ok[ new( * st.values ) ]
        end.call
      end
    end.call

    class << self
      private :new
    end

    def initialize api_client, pathname
      @model = api_client  # as we use it
      @file = CodeMolester::Config::File::Model.new path: pathname
      freeze
      nil
    end
    protected :initialize

    attr_reader :file

    Events::Exists = Models::Event.new do |pn|
      "exists, skipping - #{ pth[ pn ] }"
    end

    def init is_dry_run, pth, exists_event, before, after, info, all
      res = OK ; f = @file
      begin
        if f.exist?
          res = exists_event[ Events::Exists[ pn: f.pathname ] ]
          break
        end
        f.sections['foo'] = { }
        f.sections['foo']['bar'] = 'baz'
        res = f.write do |w|
          w.with_specificity do
            w.on_before before
            w.on_after after
            w.on_all all
          end
          if is_dry_run
            w.dry_run = true
          end
          w.escape_path = pth
        end
      end while nil
      res
    end
  end
end
