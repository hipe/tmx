
# read [#018]:#this-node-looks-funny-because-it-is-multi-domain

require 'pathname'

module Skylab ; end

module Skylab::GitViz

  module Autoloader_

    def self.[] mod, pn
      mod.module_exec do
        @dir_pathname = pn
        extend Methods__
      end ; nil
    end

    module Methods__
      def const_missing i
        Const_missing__.new( self, @dir_pathname, i ).execute
      end
      attr_reader :dir_pathname
      def to_path
        @dir_pathname.sub_ext( EXTNAME__ ).to_path
      end
      def set_dir_pn x  # compare more elaborate [sl] `init_dir_pathname`
        @dir_pathname = x ; nil
      end
    end

    class Const_missing__

      def initialize mod, dpn, i
        @i = i ; @dir_pathname = dpn ; @mod = mod
      end

      def execute
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

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  GitViz = self

end
