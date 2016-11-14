module Skylab::TestSupport

  class CLI::Visual_Client___ < ::Class.new( ::Class.new )

    Top_Client___ = self

    Branch = superclass

    Client = Branch.superclass

    class Top_Client___

      def initialize * a

        mod = a.pop
        super

        @pth_mod = mod::TestSupport
        @viz_mod = mod::TestSupport_Visual

        @_dir_path = ::File.expand_path '../../../test', mod.dir_path  # `sidesystem_path_`
      end

      def execute
        o = produce_executable_
        o and o.execute
      end

      def write_name_parts a
        a.push $PROGRAM_NAME
        a
      end

      attr_reader :_dir_path
    end

    class Client

      def initialize i, o, e, argv

        @argv = argv
        @stdin = i ; @stdout = o ; @stderr = e
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

        if @argv.length.zero?

          when_no_args

        elsif /\A--?h(?:elp)?\z/i =~ @argv.fetch( 0 )

          display_usage

        else
          produce_executable_when_nonzero_length_argv_
        end
      end

      def when_no_args
        display_usage
      end

      def display_usage
        @stderr.puts usage_line
        NIL_
      end

      def usage_line
        "usage: #{ invocation_name_ }#{ usage_args }"
      end

      def usage_args
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

      def _dir_path
        @___dir_path ||= ::File.dirname @viz_mod.dir_path
      end
    end

    class Branch

      def display_usage

        o = @stderr
        o.puts "usage: #{ invocation_name_ } [ <facility> [..]] [args]"

        o.puts
        o.puts "facilities:"

        _glob = ::File.join _dir_path, '*', 'visual.rb'
        _entries = ::Dir[ _glob ]
        _entries.each do |s|
          _ = ::File.basename ::File.dirname s
          o.puts "  #{ _ }"
        end

        nil
      end

      def produce_executable_when_nonzero_length_argv_

        s = @argv.shift

        sym = Common_::Name.via_slug( s ).as_const

        path = ::File.join _dir_path, s, 'visual'

        require path

        cls = Autoloader_.const_reduce [ sym ], @viz_mod

        Autoloader_[ cls, path ]

        o = cls.new @stdin, @stdout, @stderr, @argv

        o.receive_parent_ self, sym, s

        o.produce_executable_
      end
    end

    SPACE_ = ' '.freeze
  end
end

