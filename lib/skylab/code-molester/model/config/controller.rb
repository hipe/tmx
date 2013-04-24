module Skylab::CodeMolester

  class Model::Config::Controller

    # immutable

    CodeMolester::Services::Face::Model.enhance self do

      do_memoize  # once you create a config instance, it is *the* config.

    end

    # `new_valid` - poka yoke. there is no public `new` (#experimental)

    def self.new_valid init_blk, obj_if_ok, if_no
      r = nil
      begin
        init_blk[ st = New_Valid_.new ]
        st.pathname or break r = if_no[ Missing_Argument_[ :pathname ] ]
        inst = new( * st.values )
        r = inst.if_valid obj_if_ok, if_no
      end while nil
      r
    end

    New_Valid_ = ::Struct.new :pathname
      # (these member values in order will be flattened and passed to `new` )

    Missing_Argument_ = Model::Event.new do |i|
      "`#{ i }` is required"
    end

    class << self
      private :new
    end

    def initialize pathname
      @file = CodeMolester::Config::File::Model.new path: pathname
      freeze
      nil
    end

    attr_reader :file

    def if_valid yes, no
      @file.if_valid -> _file do
        yes[ self ]  # pattern maybe
      end, no
    end

    # `create` - create the formerly nonexistent config file with
    # some starter data (temporary..)
    #
    # `event_h` + `couldnt`
    #           * (please see downstream `write`)
    # `opt_h`   * (idem)
    # result is number of bytes or the relevant event object.

    def create opt_h, event_h
      f = @file
      couldnt = event_h.fetch :couldnt
      alt = [ -> {
        if f.exist?
          -> { couldnt[ Exists_[ pn: f.pathname ] ] }
        end }
      ].reduce nil do |_, p|
        x = p[] and break x
      end
      if alt then alt.call else
        f.sections['foo'] = { }
        f.sections['foo']['bar'] = 'baz'  # #todo
        write opt_h, event_h
      end
    end

    Services::Basic::Hash::FUN.tap do |fun|
      %i| unpack_equal unpack_superset unpack_subset repack_difference |.
          each do |i|
        define_method i, & fun[ i ]
        private i
      end
    end

    Exists_ = Model::Event.new do |pn|
      "exists, skipping - #{ pth[ pn ] }"
    end

    # `insert_valid_entity` -
    # `ent`         - the entity to insert (lexically)
    # `opt_h`       * please see `write` downstream
    # `event_h` -   + `couldnt` - last stop, receives reason
    #               + `could` - receives the entity made (before `before`!)
    #               * please see `write` downstream

    def insert_valid_entity ent, opt_h, event_h
      couldnt, could = unpack_subset event_h, :couldnt, :could
      section_name = "#{ ent.config_file_section_name } #{
        }#{ ent.natural_key.inspect }"
      this_before_me, rsn = -> sct do
        sct or break
        sct.reduce nil do |(tbm, _), s|
          cmp = section_name <=> s.section_name
          if -1 == cmp
            break
          elsif 1 == cmp
            tbm = s
          else
            break nil, Collision_[ ent: ent ]
          end
          next tbm, _
        end
      end.call @file.sections
      if rsn then couldnt[ rsn ] else
        @file.sections.insert_after section_name,
          ::Hash[ ent.rendered_config_pairs.to_a ],
          this_before_me
        could[ Inserted_[ item: ent ] ]
        write opt_h, repack_difference( event_h, :could )
      end
    end

    Collision_ = Model::Event.new do |ent|
      "#{ ent.inflection.lexemes.noun.singular } already exists, #{
        }won't clobber - #{ ent.natural_key }"
    end

    Inserted_ = Model::Event.new do |item|
      "inserted into list - #{ item.natural_key.inspect }"
    end

    Wrap_ = Model::Event.new do |upstream|
      upstream.message_function[]
    end

    Text_ = Model::Event.new do |text|
      text
    end

    Invalid_ = Model::Event.new do |rsn_o|
      rsn_o.render
    end

    # `write` - wrapper for Config::File#write
    #
    #   + `opt_h` - exactly `is_dry_run`- (implemented downstream)
    #   + `event_h`  - (any of the following, but none other than):
    #     + `couldnt` - called with an event if file already exists
    #     + `before` - called with e. immediatly before create/update
    #     + `after` - called with e. immediatly after create/update
    #     + `all` - future-proofing catch all not in above
    #     + `pth` - an `escape_path`-like for your modality

    def write opt_h, event_h
      couldnt, befor, after, all, pth = unpack_superset event_h,
        :couldnt, :before, :after, :all, :pth
      is_dry_run, = unpack_equal opt_h, :is_dry_run ; f = @file
      alt = [
        -> {
          if ! f.valid?
            -> { couldnt[ Invalid_[ rsn_o: f.invalid_reason ] ] }
          end }
      ].reduce( nil ) { |_, p| x = p[] and break x }
      if alt then alt.call else
        f.write do |w|
          w.with_specificity do
            w.on_before befor
            w.on_after after
            w.on_all all
          end
          w.dry_run = is_dry_run
          w.escape_path = pth
        end
      end
    end
  end
end
