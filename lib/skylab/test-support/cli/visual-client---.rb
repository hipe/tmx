#!/usr/bin/env ruby -w

require_relative '../core'

module Skylab::Basic

  module TestSupport_Visual  # :[#038].

    Autoloader_[ self ]

    Client_ = ::Class.new

    Branch_ = ::Class.new Client_

    class Client < Branch_

      def initialize( * )
        super

        require_relative 'test-support'
        @pth_mod = Basic_::TestSupport
        @viz_mod = Basic_::TestSupport_Visual
        @the_dir_pathname_ = Basic_.dir_pathname.join 'test'
      end

      attr_reader :the_dir_pathname_

      def execute
        o = produce_executable_
        o and o.execute
      end

      def write_name_parts a
        a.push ::File.dirname $PROGRAM_NAME
        a
      end
    end

    class Client_

      def initialize i, o, e, argv
        @stdin = i ; @stdout = o ; @stderr = e
        @argv = argv
      end

      attr_reader :pth_mod, :viz_mod

      def receive_parent_ x, sym, s

        @parent = x
        @s = s

        @viz_mod = x.viz_mod.const_get sym, false
        @pth_mod = @viz_mod

        nil
      end

      def produce_executable_
        if @argv.length.zero? or /\A--?h(?:elp)?\z/i =~ @argv.fetch( 0 )
          display_usage_
          nil
        else
          produce_executable_when_nonzero_length_argv_
        end
      end

      def display_usage_
        @stderr.puts "usage: #{ invocation_name_ }#{ usage_args_ }"
        nil
      end

      def usage_args_
        ' [args]'
      end

      def produce_executable_when_nonzero_length_argv_
        self
      end

      def invocation_name_
        write_name_parts( [] ) * SPACE_
      end

      def write_name_parts a
        @parent.write_name_parts a
        a.push @s
        a
      end

      def the_dir_pathname_
        @viz_mod.dir_pathname.dirname
      end
    end

    class Branch_

      def display_usage_

        o = @stderr
        o.puts "usage: #{ invocation_name_ } [ <facility> [..]] [args]"

        o.puts
        o.puts "facilities:"

        _a = ::Dir[ the_dir_pathname_.join( '*/visual.rb' ).to_path ]
        _a.each do | s |

          _ = ::File.basename ::File.dirname s
          o.puts "  #{ _ }"
        end

        nil
      end

      def produce_executable_when_nonzero_length_argv_

        s = @argv.shift

        sym = Callback_::Name.via_slug( s ).as_const

        pn = the_dir_pathname_.join "#{ s }/visual"

        require pn.to_path

        cls = Autoloader_.const_reduce [ sym ], @viz_mod

        Autoloader_[ cls, pn.to_path ]

        o = cls.new @stdin, @stdout, @stderr, @argv

        o.receive_parent_ self, sym, s

        o.produce_executable_
      end
    end

    SPACE_ = ' '.freeze
  end
end

::Skylab::Basic::TestSupport_Visual::Client.new( $stdin, $stdout, $stderr, ::ARGV ).execute
