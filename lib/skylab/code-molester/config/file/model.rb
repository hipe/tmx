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

      def new_with * x_a
        new_via_iambic x_a
      end

      def new_via_iambic x_a
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

    CM_.lib_.new_event_lib.selective_builder_sender_receiver self

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

    LIB_.delegating self,

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

    public def read & p

      read = Read__.new
      p and p[ read ]
      error_x = nil

      io = ( CM_.lib_.system.filesystem.normalization.upstream_IO(

          :path, @pathname.to_path ) do | *, & ev_p |

        error_x = read.receive_event ev_p[]
        false
      end )

      if io
        read_via_open_IO_and_read io, read
      else
        error_x
      end
    end

    class Read__  # experimental interface "shell" for [#hl-022]:read
      def initialize
        @error, @invalid, @is_not_file, @no_ent, @read_error = nil
      end
      attr_accessor :error, :invalid, :is_not_file, :no_ent, :read_error

      def receive_event ev
        send :"receive_#{ ev.terminal_channel_i }", ev
      end

      def receive_errno_enoent ev
        ( @no_ent || @read_error || @error || dflt )[ ev ]
      end

      def receive_wrong_ftype ev
        ( @is_not_file || @read_error || @error || dflt )[ ev ]
      end

    private
      def dflt
        -> ev do
          if ev.has_tag :exception
            raise ev.exception
          else
            raise ev.to_exception
          end
        end
      end
    end

    def read_via_open_IO_and_read io, read
      content_s = io.read
      clear_everything_but_pathname_identity_related
      @pathname_was_read = true
      @content_x = content_s  # lest infinite call stack, set this ..
      if valid?  # .. before you call this, per #here
        DID_
      else
        p = read.invalid || read.error
        if p
          p[ @invalid_reason ]
        else
          UNABLE_
        end
      end
    end

    def clear
      clear_everything_but_pathname_identity_related
      @cached_pn_exist = @pathname = nil
    end

    def clear_everything_but_pathname_identity_related
      @content_x = @invalid_reason = @pathname_was_read = @is_valid = nil
    end


    public def write &p
      w = Write__.new
      p and p[ w ]
      if valid?
        if cached_pathname_exist && ! @pathname_was_read
          wrt_when_multiple_models w
        else
          wrt_when_valid w
        end
      else
        wrt_when_invalid w
      end
    end

    def wrt_when_invalid w

      _ev = build_not_OK_event_with :invalid,
          :subject_noun, noun do |y, o|

        y << "attempt to write invalid #{ o.subject_noun } - #{
          }check if valid? first"

      end
      w.call_digraph_listeners :error, _ev
      UNABLE_
    end

    def wrt_when_multiple_models w
      _ev = build_not_OK_event_with :multiple_models,
          :path, @pathname.to_path do |y, o|
        y << "sanity - won't overwrite a path that was not first read"
      end
      w.call_digraph_listeners :error, _ev
      UNABLE_
    end

    def wrt_when_valid w
      @write_verb_i = nil
      not_OK_ev = nil
      io = CM_.lib_.system.filesystem.normalization.downstream_IO(
        :is_dry_run, w.is_dry,
        :path, @pathname.to_path,
        :on_event, -> ev do
          if ev.ok || ev.ok.nil?
            send :"wrt_when_#{ ev.terminal_channel_i }", ev, w
          else
            not_OK_ev = ev
            UNABLE_
          end
        end )
      if io
        send :"wrt_when_#{ @write_verb_i }", io, w
      else
        wrt_when_not_OK not_OK_ev, w
      end
    end

    def wrt_when_not_OK ev, w
      w.call_digraph_listeners :error, ev
      UNABLE_
    end

    def wrt_when_before_probably_creating_new_file ev, w
      @write_verb_i = :create
      w.call_digraph_listeners :before_create, resource: self,
        renderable: ev
      nil
    end

    def wrt_when_before_editing_existing_file ev, w
      @write_verb_i = :update
      @size = ev.stat.size
      w.call_digraph_listeners :before_update, resource: self,
        renderable: ev
      nil
    end

    def wrt_when_create io, w
      s = string
      bytes = io.write s
      io.close
      wrt_after_create w, bytes
    end

    def wrt_after_create w, bytes
      _ev = bld_after_created_or_updated_event w, bytes, :create
      w.call_digraph_listeners :after_create, _ev
      bytes
    end

    def wrt_when_update io, w
      s_ = string
      if @size == s_.length
        s = io.read
        is_same = s_ == s
      end
      if is_same
        io.close
        wrt_update_when_no_change w
      else
        io.rewind
        io.truncate 0
        bytes = io.write s_
        io.close
        wrt_after_update w, bytes
      end
    end

    def wrt_after_update w, bytes
      _ev = bld_after_created_or_updated_event w, bytes, :update
      w.call_digraph_listeners :after_update, _ev
      bytes
    end

    def wrt_update_when_no_change w
      _ev = build_neutral_event_with :no_change,
          :path, @pathname.to_path do |y, o|
        y << "no change: #{ pth o.path }"
      end
      w.call_digraph_listeners :no_change, _ev
      nil
    end

    def bld_after_created_or_updated_event w, bytes, i

      build_OK_event_with :"after_#{ i }",  # after_create, after_update
          :bytes, bytes, :is_dry, w.is_dry,
          :path, @pathname.to_path, :which_i, i do |y, o|

        o.is_dry and _dry = ' dry'

        _preterite = preterite_verb o.which_i

        y << "#{ _preterite } #{ pth o.path } (#{ o.bytes }#{ _dry } bytes)"
      end
    end

    Write__ = Callback_::Digraph.new

    class Write__  # `write` is very evented [#006]

      taxonomic_streams :all, :data, :structural, :text, :notice, :before, :after

      listeners_digraph error: [ :data, :all ],  # cleaned up at #open [#009]
        notice: [ :text, :all ], before: :all, after: :all,
        before_update: [ :structural, :before, :notice ],
        after_update: [ :data, :after, :notice ],
        before_create: [ :structural, :before, :notice ],
        after_create: [ :data, :after, :notice ],
        no_change: [ :data, :notice ]

      attr_accessor :dry_run
      alias_method :is_dry, :dry_run

      def is_dry= x
        @dry_run = x
      end

      def build_digraph_event x, i, esg
        if x.respond_to? :to_event
          x
        elsif x.respond_to? :each_pair
          CM_.lib_.brazen.event.inline_neutral_with i, *
            ( x.to_a.flatten( 1 ) )
        else
          self._DO_ME
        end
      end
    end

  private

    if false  # non re-integrated behavior  #todo
        (( dn = @pathname.dirname )).exist? or raise "parent directory #{
          }does not exist, will not write - #{ @pathname.dirname }"

        dn.writable? or raise "parent directory is not writable, #{
          }will not write - #{ @pathname }"
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
        str == @pathname.read  # #twice
      elsif str.length.zero?
        false
      else
        true
      end
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
