
# we are making a point of being the same "module" in a different process

::Skylab = ::Module.new
::Skylab::GitViz = ::Module.new
::Skylab::GitViz::Tasks = ::Module.new

require 'pathname'

module Skylab::GitViz::Tasks

  module Autoloader_

    def self.[] mod, path
      path = path.dup.freeze
      mod.module_exec do
        @path = path
        @dir_pathname = ::Pathname.new ::File.dirname path
        extend Methods__
      end ; nil
    end

    module Methods__
      def to_path
        @path
      end
      def dir_pathname
        @dir_pathname
      end
      def const_missing const_i
        _stem = const_i.to_s.gsub %r((?<=[a-z])(?=[A-Z])|_) do '-' end.downcase
        load (( pn = @dir_pathname.join "#{ _stem }.rb" )).to_path
        const_defined?( const_i, false ) or raise ::NameError,
          "'#{ const_i }' was not defined in #{ pn.basename }"
        const_get const_i
      end
    end
  end
end
