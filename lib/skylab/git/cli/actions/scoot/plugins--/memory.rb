module Skylab::Git

  module CLI::Actions::Scoot

    class Plugins__::Memory

      module Prepend__
        def engage
        end
        def on_pattern_string_received s
          if @do_write
            @pattern_s = s
            procure_fh && write_to_fh
          end
          SILENT_
        end
      private
        def init
          @do_write = false
          @parse = Parse_File__.curry :pattern
          @path = nil
        end
        def do_write!
          @do_write = true
        end
        def write_to_fh
          @fh.seek 0, :END
          @fh.pos.zero? or _re = 're-'
          @y_IO.write "#{ _re }writing #{ dotfile } .."
          @fh.truncate 0
          @fh.seek 0, :SET
          @fh.puts "#{ @parse.value_name }=#{ @pattern_s }"
          @fh.close
          @y_IO.puts " done."
          SILENT_
        end

        def procure_fh
          @path ||= procure_dotfile_path
          @path && procure_fh_with_dotfile_path
        end

        def procure_dotfile_path
          ok = true
          dotfile_path = dotfile.sub %r(\A~) do
            procure_env_home or ok = false
          end
          ok and dotfile_path
        end

        def procure_env_home
          ::ENV[ 'HOME' ] or report_no_env_home
        end

        def report_no_env_home
          @y << "no $HOME environment variable, cannot expand path #{ dotfile }"
          CEASE_
        end

        def procure_fh_with_dotfile_path
          ok = path_must_be_of_certain_depth
          ok &&= directory_of_a_certain_shallowitude_must_exist
          ok &&= make_directory_if_necessary
          ok && now_it_is_OK_to_open_the_file
        end

        def path_must_be_of_certain_depth
          %r(/[^/]+/) =~ @path or report_path_not_deep_enough
        end

        def report_path_not_deep_enough
          @y << "path doesn't look deep enough: #{ @path }"
          CEASE_
        end

        def directory_of_a_certain_shallowitude_must_exist
          @pn = ::Pathname.new @path
          @mkdir_pn = @pn.dirname
          @eg_home_pn = @mkdir_pn.dirname
          @eg_home_pn.exist? or report_home_dir_not_exist
        end

        def report_home_dir_not_exist
          @y << "directory must exist: #{ @eg_home_pn }"
          CEASE_
        end

        def make_directory_if_necessary
          @mkdir_pn.exist? or mkdir
        end

        def mkdir
          @y << "mkdir #{ @mkdir_pn }"
          @mkdir_pn.mkdir
        end

        def now_it_is_OK_to_open_the_file
          @fh = @pn.open 'a+'
          @pn = @mkdir_pn = @eg_home_pn = nil
          @fh && PROCEDE_
        end

      public

        def on_no_arguments argv
          @argv = argv
          @path ||= procure_dotfile_path
          @path and attempt_to_write_pattern_in_file_to_argv
        end

        def attempt_to_write_pattern_in_file_to_argv
          _parse = @parse.curry dotfile, @path, @y
          _parse.parse_for_value method( :unmarshalled_value ), -> { false }
        end

        def unmarshalled_value s
          @y << "(using stored pattern from #{ dotfile }: '#{ s }')"
          @argv << s
          PROCEDE_
        end
      end

      class Parse_File__
        class << self
          alias_method :curry, :new
        end
        def initialize value_name
          @value_name = value_name
          freeze
        end
        def initialize_copy otr
          @value_name = otr.value_name
        end
        attr_reader :value_name
        def curry pretty_path, path, y
          dupe do |otr|
            otr.path = path
            otr.pretty_path = pretty_path
            otr.y = y
          end
        end
      private
        def dupe & p
          otr = dup
          otr.initialize_dupe( & p )
          otr
        end
      protected
        def initialize_dupe
          yield self ; freeze
        end
      public
        attr_writer :path, :pretty_path, :y
        def parse_for_value yes_p, no_p
          Parse__.new( @value_name, @pretty_path, @path, @y, yes_p, no_p ).parse
        end

        class Parse__
          def initialize vname, pret_path, path, y, yes_p, no_p
            @hdr = "#{ vname }="
            @hdr_len = @hdr.length
            @no_p = no_p
            @pn = ::Pathname.new path
            @pretty_path = pret_path
            @vname = vname ; @y = y ; @yes_p = yes_p
          end
          def parse
            ok = pn_exist
            ok &&= scan_for_value
            ok ? @yes_p[ @value ] : @no_p[]
          end
        private
          def pn_exist
            @pn.exist? or report_pn_not_exist
          end
          def report_pn_not_exist
            @y << "(no #{ @pret_path })"
            CEASE_
          end
          def scan_for_value
            @fh = @pn.open 'r'
            @did_find = false
            while @line = @fh.gets
              parse_line and break
            end
            @fh.close
            @did_find
          end
          def parse_line
            @hdr == @line[ 0, @hdr_len ] and read_line
          end
          def read_line
            @did_find = true
            s = @line[ @hdr_len  .. -1 ]
            s.chomp!
            @value = s
          end
        end
      end

      prepend Prepend__
    end
  end
end
