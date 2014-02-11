module ::Skylab

  module Subsystem

    module PATHNAMES

      module Methods__

        def at * i_a
          i_a.map( & method( :send ) )
        end

        def members
          self::MEMBER_A_
        end

        alias_method :calculate, :instance_exec

        # ~ below here is members only - like the jacket ~

        a = []
        define_singleton_method :method_added do |i| a << i end

        def bin
          @bin ||= ::Skylab.dir_pathname.join '../../bin'
        end

        def binfile_prefix
          @binfile_prefix ||= 'tmx-'.freeze
        end

        def supernode_binfile
          @supernode_binfile ||= 'tmx'.freeze
        end

        PATHNAMES.const_set :MEMBER_A_, a.freeze
      end

      extend Methods__

    end
  end
end
