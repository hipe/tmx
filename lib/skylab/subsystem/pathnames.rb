module ::Skylab

  module Subsystem

    module PATHNAMES

      class << self

        def at * i_a
          i_a.map( & method( :send ) )
        end

        alias_method :calculate, :instance_exec

        def bin
          @bin ||= ::Skylab.dir_pathname.join( '../../bin' )
        end

        def binfile_prefix
          @binfile_prefix ||= 'tmx-'.freeze
        end

        def supernode_binfile
          @supernode_binfile ||= 'tmx'.freeze
        end

        def tmpdir
          @tmpdir ||= ::Pathname.new(
            Subsystems_::Headless::Services::Tmpdir.tmpdir )
        end
      end
    end
  end

  module Subsystems_

    def self.const_missing c
      if ! ::Skylab.const_defined? c, false
        require ::Skylab.dir_pathname.join( "#{ Quick_[ c ] }/core" ).to_s
      end
      const_set c, ::Skylab.const_get( c, false )
    end

    Quick_ = -> c do
      c.to_s.gsub( /(?<=[a-z])([A-Z])/ ) { "-#{ $1 }" }.downcase
    end

  end
end
