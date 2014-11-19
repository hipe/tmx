module Skylab::CodeMolester

  module Models

    module Config

      class Controller

    # immutable

    LIB_.model_enhance self, -> do

      do_memoize  # once you create a config instance, it is *the* config.

    end

    class << self

      def new_valid p, _OK_p, not_OK_p  # poka yoke. there is no public `new`
        st = Shell_for_New_Valid__.new
        p[ st ]
        if st.pathname
          new( * st.values ).normalize_via_yes_or_no _OK_p, not_OK_p
        else
          not_OK_p[ Missing_Argument__[ :name_i, :pathname ] ]
        end
      end

      private :new
    end

    Shell_for_New_Valid__ = ::Struct.new :pathname

    Missing_Argument__ = Event_.new do |name_i|
      "`#{ name_i }` is required"
    end

    def initialize pn
      @file_model = CM_::Config::File::Model.build_with :path, pn
      freeze
    end

    def file
      @file_model
    end

    def normalize_via_yes_or_no yes_p, no_p
      @file_model.normalize_via_yes_or_no -> _file do
        yes_p[ self ]  # pattern maybe
      end, no_p
    end

    # `create` - create the formerly nonexistent config file with
    # some starter data (temporary..)
    #
    # `event_h` + `couldnt`
    #           * (please see downstream `write`)
    # `opt_h`   * (idem)
    # result is number of bytes or the relevant event object.

    def create opt_h, event_h
      o = @file_model
      couldnt = event_h.fetch :couldnt
      alt = [ -> {
        if o.exist?
          -> do
            _ev = Exists__[ :pn, o.pathname ]
            couldnt[ _ev ]
          end
        end }
      ].reduce nil do |_, p|
        x = p[] and break x
      end
      if alt then alt.call else
        o.sections['foo'] = {}
        o.sections['foo']['bar'] = 'baz'  # #todo
        write opt_h, event_h
      end
    end

  private

    LIB_.hash_lib.pairs_at(
      :unpack_equal, :unpack_superset,
      & method( :define_method ) )

  public

    Exists__ = Event_.new do |pn|
      "exists, skipping - #{ escape_path pn.to_path }"
    end

    # `insert_valid_entity` -
    # `ent`         - the entity to insert (lexically)
    # `opt_h`       * please see `write` downstream
    # `event_h` -   + `couldnt` - last stop, receives reason
    #               + `could` - receives the entity made (before `before`!)
    #               * please see `write` downstream

    def insert_valid_entity ent, opt_h, event_h
      Config_::Actors_::Create[ ent, opt_h, event_h, @file_model, self ]
    end


    Wrap_ = Event_.new do |upstream|
      upstream.message_proc[]
    end

    Text_ = Event_.new do |text|
      text
    end

    Invalid_ = Event_.new do |rsn_o|
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

    def write opt_h, event_h
      couldnt, befor, after, all = unpack_superset event_h,
        :couldnt, :before, :after, :all
      is_dry_run, = unpack_equal opt_h, :is_dry_run ; fm = @file_model
      alt = [
        -> {
          if ! fm.valid?
            -> { couldnt[ Invalid_[ :rsn_o, fm.invalid_reason ] ] }
          end }
      ].reduce( nil ) { |_, p| x = p[] and break x }
      if alt
        alt.call
      else
        fm.write do |w|
          w.with_specificity do
            w.on_before befor
            w.on_after after
            w.on_all all
          end
          w.dry_run = is_dry_run
        end
      end
    end
      end
    end
  end
end
