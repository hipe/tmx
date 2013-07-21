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
      end
    end
  end
end
