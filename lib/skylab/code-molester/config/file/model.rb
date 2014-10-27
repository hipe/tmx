module Skylab::CodeMolester

  module Config

  module File

  class Model

    module Foofer # (ignore)

      # (while [#ps-101] (cover [cb] digraph viz) is open..) (multiple graphs
      # in one file, specifically)

      Callback_[ self, :employ_DSL_for_digraph_emitter ]
      listeners_digraph wizzle: :paazle
    end

    class << self

      def build_with * x_a
        build_via_iambic x_a
      end

      def build_via_iambic x_a
        if 1 == x_a.length
          raise ::ArgumentError, "no more '#{ x_a.first.class }' arguments supported - pls change to iambic"
        end
        new do
          process_iambic_fully x_a
        end
      end

      private :new
    end

    def initialize & p
      instance_exec( & p )
    end

  private

    def process_iambic_fully x_a
      st = St__.new
      x_a.each_slice 2 do |i, x|
        st[ i ] = x
      end
      path, @content_x, @entity_noun_stem = st.values
      if path
        @pathname = nil
        self.path = path
      else
        @cached_pn_exist = nil
        @pathname = path
      end
      @invalid_reason = nil
      @pathname_was_read = nil
      @is_valid = nil
    end
    #
    St__ = ::Struct.new :path, :string, :entity_noun_stem

  public

    attr_reader :entity_noun_stem, :pathname

    Lib_::Delegating.call self,

      :to, :sexp, :if, -> { valid? },

        [ :content_items,
          :has_name,
          :sections,
          :set_mixed_at_name,
          :value_items ],

      :to, :sexp, :to_method, :aref, :if, -> { valid? }, :[],

      :to, :@pathname, :if, -> { @pathname },
        [ :dirname,
          :exist?,
          :writable? ]

    def fetch name_i_or_s, &p  # #comport to #box-API
      name_s = name_i_or_s.to_s
      if valid?
        r = @content_x.lookup_with_s_else_p name_s, false
      end
      if r then r elsif p then p.call else
        raise ::KeyError.exception "key not found: #{ name_i_or_s.inspect }"
      end
    end

    def []= kx, vx
      sexp.set_mixed_at_name vx, kx
      vx
    end

    def noun
      @entity_noun_stem || 'config file'
    end

    def path
      @pathname.to_s if @pathname # a simpler, perhaps more familiar interface
    end                           # for the outside world

    def cached_pathname_exist  # assumes pathname
      if @cached_pn_exist.nil?
        @cached_pn_exist = !! @pathname.exist?
      end
      @cached_pn_exist
    end

    def path= x
      @pathname and raise "semi-immutable - won't overwrite existing path"
      @pathname = x ? ::Pathname.new( x.to_s ) : x
      @cached_pn_exist = nil
      x
    end

    def has_content  # unaware of validity. *may* false positive
      if @content_x
        @content_x.has_content
      else
        cached_pathname_exist  # may false-positive on empty string
      end
    end

    def content= str
      @is_valid = nil
      @content_x = str
    end

    def sexp
      @is_valid.nil? and valid?
      @is_valid and @content_x
    end

    def string
      @is_valid.nil? and valid?
      @is_valid and @content_x.unparse
    end

    def normalize_via_yes_or_no yes_p, no_p
      if valid?
        yes_p[ self ]
      else
        no_p[ @invalid_reason ]
      end
    end

    def valid?
      @is_valid.nil? and determine_valid
      @is_valid
    end

    def invalid_reason
      @is_valid.nil? and valid?
      @invalid_reason
    end

  private

    def determine_valid  # assume valid is nil
      if @content_x
        descend = true
      elsif @content_x.nil?
        if @pathname and cached_pathname_exist
          read  # will set @content_x, call valid?, come back here from #here
        else
          @content_x = ''
          descend = true
        end
      else
        @is_valid = false
      end
      if descend
        determine_valid_via_execute_parse
      end
      nil
    end

    def determine_valid_via_execute_parse
      parser = Config_::File::Parser.instance
      r = parser.parse @content_x
      if r
        @content_x = r.sexp  # goes from being a string to a sexp
        @invalid_reason = nil
        @is_valid = true
      else
        # (leave content as the invalid string)
        ( @pathname && @pathname_was_read ) and use_pn = @pathname
        @invalid_reason = CM_::Invalid_Reason__.new parser, use_pn
        @is_valid = false
      end
      nil
    end

    def read & p  # :+[#hl-022] for sure
      @pathname or raise "cannot read - no pathname associated with this #{ noun }"
      st = Read__.new ; p and p[ st ]
      esc_p = st.escape_path
      st.escape_path = -> pn_x do
        esc_p && esc_p.respond_to?( :escape_path ) and never  # #todo
        esc_p ||= Default_escape_path__
        esc_p[ pn_x ]
      end
      if cached_pathname_exist
        r = read_when_path_exist st
      else
        r = read_when_path_not_exist st
      end
      r
    end ; public :read
    #
    Read__ = ::Struct.new :error, :read_error, :no_ent, :is_not_file,
      :invalid, :escape_path
    #
    Default_escape_path__ = -> pn { pn.basename }  # a nice safe common denom.

    def read_when_path_exist st
      stat = @pathname.stat
      if 'file' == stat.ftype
        r = read_when_is_file st
      else
        r = read_when_is_not_file st, stat
      end
      r
    end

    def read_when_is_file st
      content_s = @pathname.read
      clear_everything_but_pathname_identity_related
      @pathname_was_read = true
      @content_x = content_s  # lest infinite call stack, set this ..
      r = if valid?  # .. before you call this, per #here
        true
      elsif (( p = st.invalid || st.error ))
        p[ @invalid_reason ]
      else
        false
      end
      r
    end

    def clear
      clear_everything_but_pathname_identity_related
      @cached_pn_exist = @pathname = nil
    end

    def clear_everything_but_pathname_identity_related
      @content_x = @invalid_reason = @pathname_was_read = @is_valid = nil
    end

    def read_when_is_not_file st, stat
      p = st.is_not_file || st.read_error || st.error
      p ||= -> pn, ftype do
        raise "expected #{ noun } to be of type 'file', had #{ ftype } #{
          }- #{ st.escape_path[ pn ] }"
      end
      p[ @pathname, stat.ftype ]
    end

    def read_when_path_not_exist st
      p = st.no_ent || st.read_error || st.error || -> pn do
        raise ::Errno::ENOENT.exception "#{ st.escape_path[ pn ] }"
        # the class itself writes "No such file or directory - #{ .. }" for us
      end
      p[ @pathname ]
    end

  public

    def write &p
      write_with_is_dry false, &p
    end

    def write_with_is_dry is_dry, &p
      w = Write__.new ; p and p[ w ] ; is_dry and w.is_dry_notify
      w.escape_path ||= Default_escape_path__
      @pathname or raise "cannot write - #{
        }no pathname associated with this #{ noun }"
      valid? or raise "attempt to write invalid #{ noun } - check if valid? first"
      if cached_pathname_exist
        @pathname_was_read or fail "sanity - won't overwrite a pathname #{
          }that was not first read"
        r = write_when_update w
      else
        r = write_when_create w
      end
      r
    end

    Write__ = Callback_::Digraph.new
    class Write__  # `write` is very evented [#006]

      taxonomic_streams :all, :structural, :text, :notice, :before, :after

      listeners_digraph error: [ :text, :all ],
        notice: [ :text, :all ], before: :all, after: :all,
        before_update: [ :structural, :before, :notice ],
        after_update: [ :structural, :after, :notice ],
        before_create: [ :structural, :before, :notice ],
        after_create: [ :structural, :after, :notice ],
        no_change: [ :notice, :text ]

      event_factory -> { Callback_::Event::Factory::Isomorphic.new Events__ }

      attr_accessor :dry_run
      alias_method :is_dry_run, :dry_run
      attr_accessor :escape_path

      def is_dry_notify
        @dry_run = true
      end

      module Events___
        # filled with joy
      end

      module Events__
        Text = Callback_::Event::Factory::Datapoint
        Structural = Callback_::Event::Factory::Structural.new 2, nil, Events___
      end
    end

  private

    def write_when_create w
      begin
        @cached_pn_exist = nil
        before_create w

        (( dn = @pathname.dirname )).exist? or raise "parent directory #{
          }does not exist, will not write - #{ @pathname.dirname }"

        dn.writable? or raise "parent directory is not writable, #{
          }will not write - #{ @pathname }"

          # somewhat arbitrarily the above are not considered UI-level errors
          # hence they use neither the emitter nor `escape_path` (for now)

        bytes = nil
        ( w.is_dry_run ? Lib_::Dry_IO_stub[] : @pathname ).open 'a' do |fh|
          bytes = fh.write string  # 'a' not 'w' to fail gloriously
        end
        @cached_pn_exist = true  # hopefully ok, might bite

        after_create w, bytes
        r = bytes
      end while nil
      r
    end

    def before_create w
      w.call_digraph_listeners :before_create, resource: self,
        message_proc: -> { "creating #{ w.escape_path[ @pathname ] }" } ; nil
    end

    def after_create w, bytes
      w.call_digraph_listeners :after_create, bytes: bytes, is_dry: w.is_dry_run,
        message_proc: -> do
          "created #{ w.escape_path[ @pathname ] } (#{ bytes }#{
            }#{ " dry" if w.is_dry_run } bytes)"
        end ; nil
    end

    def write_when_update w
      begin
        str = string ; is_dry = w.is_dry_run  # thread safety HA
        str == @pathname.read and break( update_when_no_change w )  # #twice
        before_update w
        @pathname.writable? or raise "path is not writable, cannot #{
          }write - #{ @pathname }"
        bytes = nil
        ( is_dry ? Lib_::Dry_IO_stub[] : @pathname ).open 'w' do |fh|
          bytes = fh.write str
        end
        after_update w, bytes
        r = bytes
      end while nil
      r
    end

    def update_when_no_change w
      w.call_digraph_listeners :no_change, "no change: #{ w.escape_path[ @pathname ] }" ; nil
    end

    def before_update w
      w.call_digraph_listeners :before_update, resource: self,
        message_proc: -> { "updating #{ w.escape_path[ @pathname ] }" } ; nil
    end

    def after_update w, bytes
      w.call_digraph_listeners :after_update, bytes: bytes, is_dry: w.is_dry_run,
        message_proc: -> do
          "updated #{ w.escape_path[ @pathname ] } (#{ bytes }#{
            }#{ ' dry' if w.is_dry_run } bytes)"
        end ; nil
    end

  public

    def modified?  # explained at [#004]
      @pathname or fail "sanity - it is meaningless to ask if `modified?` #{
        } on a #{ noun } not associated with any pathname."
      valid? or fail "sanity - invalid files should not be written to disk #{
        }hence whether such files are modified is the wrong question to ask."
      # in cases where the file has not yet been written to disk consider
      # our structure as modified IFF we flatten down into anything other
      # than the empty string so that we avoid writing empty file to disk
      str = string
      if cached_pathname_exist
        r = str == @pathname.read  # #twice
      elsif str.length.zero?
        r = false
      else
        r = true
      end
      r
    end

    def some_names_notify
      if valid?
        res_a = @content_x.any_names_notify
      end
      res_a || EMPTY_A_
    end

  end
    File_ = self
  end
  end
end
