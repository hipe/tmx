module Skylab::Cull

  class Models::Config::Controller

    module Events
    end

    def do_cache  # be careful!
      true
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

    def insert_valid_data_source src, d, v, e, i
      insert_valid_item 'data-source', src, d, v, e, i
    end

    Collision = Models::Event.new do |section_name|
      "name collision with #{ section_name.inspect }"
    end

    Inserted = Models::Event.new do |item|
      "inserted into list - #{ item.name.inspect }"
    end

    def insert_valid_item sect_name, cont, dry, verbose, error_event, info_ev
      section_name = "#{ sect_name } #{ cont.name.inspect }"
      res = nil ; this_before_me = nil
      stay = true
      sct = @file.sections
      sct and sct.each do |s|
        cmp = section_name <=> s.section_name
        if -1 == cmp
          break
        elsif 1 == cmp
          this_before_me = s
        else
          res = error_event[ Collision[ section_name: section_name ] ]
          break( stay = false )
        end
      end
      if ! stay then res else
        b_h = cont.body_h
        @file.sections.insert_after section_name, b_h, this_before_me if ! dry
        info_ev[ Inserted[ item: cont ] ]
        write dry, error_event, info_ev
      end
    end
    protected :insert_valid_item

    Wrap = Models::Event.new do |upstream|
      upstream.message_function[]
    end

    Text = Models::Event.new do |text|
      text
    end

    Invalid = Models::Event.new do |rsn_o|
      rsn_o.render
    end

    def write dry, error_event, info_event
      if @file.valid?
        @file.write do |w|
          w.with_specificity do
            w.on_text do |e|
              info_event[ Text[ text: e ] ]
            end
            w.on_structural do |e|
              info_event[ Wrap[ upstream: e ] ]
            end
          end
          w.dry_run = dry
        end
      else
        error_event[ Invalid[ rsn_o: @file.invalid_reason ] ]
      end
    end
  end
end
