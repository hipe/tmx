module Skylab ; end

module Skylab::Callback

  def self.[] mod, * x_a
    self::Bundles.apply_iambic_on_client x_a, mod
  end

  module Autoloader

    def self.[] mod, x=nil
      mod.module_exec do
        if x
          if :boxxy == x
            extend Boxxy_Methods__, Deferred_Methods__
          else
            @dir_pathname = x
            extend Methods__
          end
        else
          extend Deferred_Methods__
        end
      end ; nil
    end

    def self.at *a
      @at_h ||= {}
      a.map do |i|
        @at_h.fetch i do
          @at_h[ i ] = method i
        end
      end
    end

    # ~ :+[#ss-002] the below methods duplicate and purify their predecessors

    def self.require_stdlib const_i
      require const_i.downcase.to_s  # until it's useful to, no inflection
      ::Object.const_get const_i
    end

    define_singleton_method :require_subsystem, -> do
      sl_path = -> do
        x = Callback.dir_pathname.dirname.to_path ; sl_path = -> { x } ; x
      end
      -> const_i do
        require "#{ sl_path[] }/#{ Name.from_const( const_i ).as_slug }/core"
        ::Skylab.const_get const_i, false
      end
    end.call

    module Boxxy_Methods__
      def const_defined? const_i, up=false
        is_indexed_for_boxxy or index_for_boxxy
        yes = @boxxy_h[ const_i ]
        yes or super
      end
      def constants
        if ! is_indexed_for_boxxy
          index_for_boxxy
        end
        [ * super, * @boxxy_a ].uniq
      end
      attr_reader :is_indexed_for_boxxy
    private
      def index_for_boxxy
        @is_indexed_for_boxxy = true ; a = [] ; h = {}
        dir_pathname.children( false ).each do |pn|
          path = pn.to_path  # #storypoint-50
          slug, extname = path.split SPLIT_EXTNAME_RX_
          ! extname || extname =~ EXTENSION_PASS_FILTER_RX_ or next
          const_i = Constify_if_possible_[ slug ]
          const_i or next
          h[ const_i ] and next  # e.g both "foo.rb" and "foo/"
          a << const_i ; h[ const_i ] = true
        end
        @boxxy_a = a.freeze ; @boxxy_h = h.freeze ; nil
      end
    end

    EXTNAME_ = '.rb'.freeze
    SPLIT_EXTNAME_RX_ = %r((?=\.[^.]+\z))
    EXTENSION_PASS_FILTER_RX_ = /\A(?:#{ ::Regexp.escape EXTNAME_ }|)\z/

    module Deferred_Methods__
      def const_missing i
        insist_on_dir_pathname
        const_missing i
      end
      def dir_pathname
        insist_on_dir_pathname
        dir_pathname
      end
      def to_path
        insist_on_dir_pathname
        to_path
      end
      def get_const_missing name_x, _guess_i  # #hook-in
        insist_on_dir_pathname
        Const_Missing__.new self, @dir_pathname, name_i
      end
    private
      def insist_on_dir_pathname
        s_a = name.split '::'
        last_s = s_a.pop
        mod = s_a.reduce( ::Object ) { |m, s| m.const_get s, false }
        extend Methods__
        set_dir_pn mod.dir_pathname.join last_s.gsub( '_', '-' ).downcase ; nil
      end
    end

    module Methods__
      def const_missing i
        Const_Missing__.new( self, @dir_pathname, i ).load_and_get
      end
      def const_missing_class
        :_has_one_  # #comport to oldschoool a.l
      end
      attr_reader :dir_pathname
      def to_path
        @dir_pathname.sub_ext( EXTNAME_ ).to_path
      end
      def get_const_missing name_x, _guess_i  # #hook-in
        Const_Missing__.new self, @dir_pathname, name_x
      end
      def set_dir_pn x  # compare more elaborate [sl] `init_dir_pathname`
        @dir_pathname = x ; nil
      end
      attr_reader :stowaway_h
    private
      def stowaway i, path
        ( @stowaway_h ||= {} )[ i ] = path ; nil
      end
    end

    class Const_Missing__

      def initialize mod, dpn, i
        @dir_pathname = dpn ; @mod = mod ;
        @name = Name.from_variegated_symbol i
      end

      attr_reader :mod

      def const
        @name.as_const
      end

      def load_and_get correction_proc=nil
        @correction_proc = correction_proc
        @slug = @name.as_slug
        @d_pn = @dir_pathname.join @slug
        @f_pn = @d_pn.sub_ext EXTNAME_
        if @f_pn.exist?
          when_file_exists
        elsif @d_pn.exist?
          when_dir_exists
        elsif h = @mod.stowaway_h and @stowaway_path = h[ @name.as_const ]
          load_stowaway
        else
          when_neither_file_nor_dir_exist
        end
      end

    private

      def when_neither_file_nor_dir_exist
        raise ::NameError, "uninitialized constant #{
         }#{ @mod.name }::#{ @name.as_const } #{
          }and no directory[file] #{
           }#{ @d_pn.relative_path_from @dir_pathname }[#{ EXTNAME_ }]"
      end

      def when_file_exists
        load @f_pn.to_path
        after_file_was_loaded
      end

      def load_stowaway
        require @mod.dir_pathname.join( @stowaway_path ).to_path
        after_file_was_loaded
      end

      def after_file_was_loaded
        verify_const_defined_and_emit_correction
        mod = @mod.const_get @name.as_const
        if ! mod.respond_to? :dir_pathname
          enhance_loaded_value mod
        elsif ! mod.dir_pathname  # if a child class, e.g
          mod.set_dir_pn @d_pn
        end
        mod
      end

      def verify_const_defined_and_emit_correction
        i = @name.as_const or raise ::LoadError, say_cant_resolve_valid_cname
        @mod.const_defined? i, false or raise ::LoadError, say_not_defined
        @correction_proc and @correction_proc[] ; nil
      end

      def say_cant_resolve_valid_cname
        "can't resolve a valid const name from #{
          }'#{ @name.as_variegated_symbol }'"
      end

      def say_not_defined
        "'#{ @name.as_const }' was not defined in #{ @f_pn.basename }"
      end

      def when_dir_exists
        c_pn = @d_pn.join CORE_FILE__
        if c_pn.exist?
          @f_pn = c_pn
          when_file_exists
        else
          mod = @mod.const_set @name.as_const, ::Module.new
          enhance_loaded_value mod
          mod
        end
      end ; CORE_FILE__ = "core#{ EXTNAME_ }".freeze

      def enhance_loaded_value mod
        mod.respond_to? :module_exec and  # not all autoloaded objects are mods
          Autoloader[ mod, @d_pn ] ; nil
      end
    public
      def correction_notification i
        @name.as_const == i or fail "sanity"  # just for compat with old
      end
    end
  end

  class Name  # will freeze any string it is constructed with
    # this only supports the simplified inflection necessary for this app.
    class << self
      def from_const const_i
        allocate_with :initialize_with_const_i, const_i
      end
      def from_human human_s
        allocate_with :initialize_with_human, human_s
      end
      def from_local_pathname pn
        allocate_with :initialize_with_local_pathname, pn
      end
      def from_variegated_symbol i
        allocate_with :initialize_with_variegated_symbol, i
      end
      private :new
    private
      def allocate_with method_i, x
        new = allocate
        new.send method_i, x
        new
      end
    end
  private
    def initialize_with_const_i const_i
      @as_const = const_i
      @const_is_resolved = true
    end
    def initialize_with_human human_s
      @as_human = human_s.freeze
      @as_slug = human_s.gsub( SPACE__, DASH__ ).downcase.freeze
      initialize
    end
    def initialize_with_local_pathname pn
      @as_slug = pn.sub_ext( THE_EMPTY_STRING__ ).to_path.freeze
      initialize
    end
    def initialize_with_variegated_symbol i
      @as_variegated_symbol = i
      @as_slug = i.to_s.gsub( NORMALIZE_CONST_RX__, DASH__ ).
        gsub( UNDERSCORE__, DASH__ ).downcase.freeze
      initialize
    end
    def initialize
      @const_is_resolved = false
    end
  public
    def as_const
      @const_is_resolved || resolve_const
      @as_const
    end
    def as_doc_slug
      @as_doc_slug ||= build_doc_slug
    end
    def as_human
      @as_human ||= build_human
    end
    def as_slug
      @as_slug ||= build_slug
    end
    def as_variegated_symbol
      @as_variegated_symbol ||= build_variegated_symbol
    end
  private
    def build_doc_slug
      as_normalized_const.gsub( SLUGIFY_CONST_RX__, & :downcase ).
        gsub( UNDERSCORE__, DASH__ ).freeze
    end
    def build_human
      as_slug.gsub( DASH__, SPACE__ ).freeze
    end
    def build_slug
      as_normalized_const.gsub( UNDERSCORE__, DASH__ ).downcase.freeze
    end
    def build_variegated_symbol
      as_slug.gsub( DASH__, UNDERSCORE__ ).intern
    end
    def as_normalized_const
      as_const.to_s.gsub NORMALIZE_CONST_RX__, UNDERSCORE__
    end
    def resolve_const
      @const_is_resolved = true
      @as_const = Constify_if_possible_[ as_variegated_symbol.to_s ]
    end

    DASH__ = '-'.freeze
    NORMALIZE_CONST_RX__ = /(?<=[a-z])(?=[A-Z])/
    SLUGIFY_CONST_RX__ = /[A-Z](?=[a-z])/
    SPACE__ = ' '.freeze
    THE_EMPTY_STRING__ = ''.freeze
    UNDERSCORE__ = '_'.freeze
  end

  Constify_if_possible_ = -> do
    white_rx = %r(\A[a-z][-_a-z0-9]*\z)i
    gsub_rx = /([-_]+)([a-z])?/
    -> s do
      if white_rx =~ s
        s_ = s.gsub( gsub_rx ) do
          "#{ '_' * $~[1].length }#{ $~[2].upcase if $~[2] }"
        end
        s_[0] = s_[0].upcase
        s_.intern
      end
    end
  end.call

  Oxford = -> separator, none, final_sep, a do
    if a.length.zero?
      none
    else
      p = -> do
        h = { 0 => nil, 1 => final_sep }
        h.default_proc = -> _, _ do separator end
        h.method :[]
      end.call
      last = a.length - 1
      a[ 1 .. -1 ].each_with_index.reduce( [ a.first ] ) do |m, (s, d)|
        m << p[ last - d ] ; m << s ; m
      end * ''
    end
  end

  Oxford_or = Oxford.curry[ ', ', '[none]', ' or ' ]
  Oxford_and = Oxford.curry[ ', ', '[none]', ' and ' ]

  Require_legacy_core_ = -> do
    p = -> do
      require_relative '..'
      require 'skylab/basic/core'

      [ :Basic, :MetaHell ].each do |i|
        const_set i, ::Skylab.const_get( i, false )
      end
      p = -> { } ; nil
    end
    -> { p[] }
  end.call

  require 'pathname'

  Autoloader[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  stowaway :TestSupport, 'test/test-support'

  Callback = self

end
