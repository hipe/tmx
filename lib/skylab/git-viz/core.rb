
# read [#018]:#this-node-looks-funny-because-it-is-multi-domain

require 'pathname'

module Skylab ; end

module Skylab::GitViz

  module Autoloader_

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

    module Boxxy_Methods__
      def const_defined? const_i, up=false
        is_indexed_for_boxxy or index_for_boxxy
        yes = @boxxy_h[ const_i ]
        yes or super
      end
      def constants
        self._NOT_IMPLEMENTED  # not yet, can be.
      end
      attr_reader :is_indexed_for_boxxy
    private
      def index_for_boxxy
        @is_indexed_for_boxxy = true ; h = {}
        dir_pathname.children( false ).each do |pn|
          slug = pn.sub_ext( '' ).to_path
          SLUG_WHITE_RX__ =~ slug or next
          h[ Constate_[ slug ] ] = true
        end
        @boxxy_h = h.freeze ; nil
      end
      SLUG_WHITE_RX__ = /\A[a-z]/
    end

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
      def get_const_missing i  # #hook-in
        insist_on_dir_pathname
        Const_Missing__.new self, @dir_pathname, i
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
      attr_reader :dir_pathname
      def to_path
        @dir_pathname.sub_ext( EXTNAME__ ).to_path
      end
      def get_const_missing i  # #hook-in
        Const_Missing__.new self, @dir_pathname, i
      end
      def set_dir_pn x  # compare more elaborate [sl] `init_dir_pathname`
        @dir_pathname = x ; nil
      end
    end

    class Const_Missing__

      def initialize mod, dpn, i
        @i = i ; @dir_pathname = dpn ; @mod = mod
      end

      def const ; @i end ; attr_reader :mod

      def load_and_get _correction_proc=nil
        @stem = @i.to_s.gsub( %r((?<=[a-z])(?=[A-Z])|_), '-' ).downcase
        @d_pn = @dir_pathname.join @stem
        @f_pn = @d_pn.sub_ext EXTNAME__
        if @f_pn.exist?
          when_file_exists
        elsif @d_pn.exist?
          when_dir_exists
        else
          when_neither_file_nor_dir_exist
        end
      end

    private

      def when_neither_file_nor_dir_exist
        raise ::NameError, "uninitialized constant #{ @mod.name }::#{ @i } #{
          }and no directory[file] #{
           }#{ @d_pn.relative_path_from @dir_pathname }[#{ EXTNAME__ }]"
      end

      def when_file_exists
        load @f_pn.to_path
        @mod.const_defined? @i, false or raise ::LoadError,
          "'#{ @i }' was not defined in #{ @f_pn.basename }"
        mod = @mod.const_get @i
        if ! mod.respond_to? :dir_pathname
          enhance_loaded_value mod
        elsif ! mod.dir_pathname  # if a child class, e.g
          mod.set_dir_pn @d_pn
        end
        mod
      end

      def when_dir_exists
        c_pn = @d_pn.join CORE_FILE__
        if c_pn.exist?
          @f_pn = c_pn
          when_file_exists
        else
          mod = @mod.const_set @i, ::Module.new
          enhance_loaded_value mod
          mod
        end
      end

      def enhance_loaded_value mod
        Autoloader_[ mod, @d_pn ] ; nil
      end
    end

    EXTNAME__ = '.rb'.freeze
    CORE_FILE__ = "core#{ EXTNAME__ }".freeze
  end

  Constate_ = -> do  # 'constantize' and 'constantify' are taken
    rx = %r((?:(-)|^)([a-z]))
    -> s do
      s.gsub( rx ) { "#{ '_' if $~[1] }#{ $~[2].upcase }" }.intern
    end
  end.call

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  GitViz = self

end
