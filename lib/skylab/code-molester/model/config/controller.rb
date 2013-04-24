module Skylab::CodeMolester

  class Model::Config::Controller

    CodeMolester::Services::Face::Model.enhance self do

      do_memoize  # once you create a config instance, it is *the* config.

    end

    -> do  # `new_valid`

      Init_ = ::Struct.new :pathname
      define_singleton_method :new_valid do |init, obj_if_ok, msg_if_not_ok|
        init[ st = Init_.new ]
        -> do
          st.pathname or break msg_if_not_ok[ '`pathname` is required' ]
          obj_if_ok[ new( * st.values ) ]
        end.call
      end
    end.call

    class << self
      private :new
    end

    def initialize pathname
      @file = CodeMolester::Config::File::Model.new path: pathname
      freeze
      nil
    end

    attr_reader :file

    module Events
    end

    Events::Exists = Model::Event.new do |pn|
      "exists, skipping - #{ pth[ pn ] }"
    end

    # `create` - wrapper for Config::File#write
    # `pth` is a function is used to escape filesystem pathnames
    # `exists_event` will be called if the file already exists, it will
    # be passed an `Events::Exists` object. `befor` and `after` will receive
    # events with metadata immediately before and after the file is written.
    # `all` is a catch-all for other eventws.

    def create is_dry_run, pth, exists_event, befor, after, all
      f = @file
      begin
        if f.exist?
          res = exists_event[ Events::Exists[ pn: f.pathname ] ]
          break
        end
        f.sections['foo'] = { }
        f.sections['foo']['bar'] = 'baz'
        res = f.write do |w|
          w.with_specificity do
            w.on_before befor
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

    def insert_valid_entity ent, opt_h, if_yes, if_no
      d, _v = Services::Basic::Hash::FUN.unpack[opt_h, :is_dry_run, :be_verbose]
      section_name = "#{ ent.config_file_section_name } #{
        }#{ ent.natural_key.inspect }"
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
        b_h = ::Hash[ ent.body_field_pairs.to_a ]
        @file.sections.insert_after section_name, b_h, this_before_me if ! d
        if_yes[ Inserted[ item: ent ] ]
        write d, if_no, if_yes
      end
    end

    Collision = Model::Event.new do |section_name|
      "name collision with #{ section_name.inspect }"
    end

    Inserted = Model::Event.new do |item|
      "inserted into list - #{ item.natural_key.inspect }"
    end

    Wrap = Model::Event.new do |upstream|
      upstream.message_function[]
    end

    Text = Model::Event.new do |text|
      text
    end

    Invalid = Model::Event.new do |rsn_o|
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
