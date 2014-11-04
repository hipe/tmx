module Skylab::FileMetrics

  class CLI < Face_::CLI::Client

    use :hi, [ :last_hot, :as, :command ]

    set :node, :ping, :invisible

    def ping
      @y << "hello from file metrics."
      :hello_from_file_metrics
    end

    # lost indent
      def op_common_head
        op = command.op

        req = ( @param_h ||= { } )

        req[:exclude_dirs] = ['.*']

        op.on('-D', '--exclude-dir DIR',
          'Folders whose basename match this pattern will not be',
          'descended into. It can be specified multiple times',
          'with multiple patterns to narrow the search.',
          'If not provided, the default is to skip folders whose',
          "name starts with a '.' (period). To include such",
          'dirs, specify "--exclude-dirs=[]" the first time you',
          'use this option in the command. (it has the effect',
          'of clearing the "blacklist" of directories to skip)') do |dir|
            if '[]' == dir
              req[:exclude_dirs].clear
            else
              req[:exclude_dirs].push dir
            end
        end

        req[:include_names] = []

        op.on('-n', '--name NAME',
          "e.g. --name='*.rb'. When present, this limits the",
          'files analyzed to the ones whose basename matches',
          'this pattern. It can be specified multiple times to',
          'add multiple filename patterns, which will broaden',
          'the search. You should use single quotes to avoid',
          'shell expansion.',
          ' ',
          'When PATH is a file, this option is ignored.'
        ) do |pattern|
          req[:include_names].push pattern
        end

        # e.g - fatal error warning notice info debug trace

        ( volume_a = [ :info_volume, :debug_volume, :trace_volume ].freeze ).
          each { |k| req[k] = nil }  # so we can fetch them
        op.on('-v', '--verbose',
          'e.g. show the generated {find|wc} commands we (would) use, etc',
          '(try using multiple -v for more detail)') do
          not_yet_set = volume_a.detect { |k| ! req[ k ] }
          if not_yet_set then req[ not_yet_set ] = true else
            @did_emit_verbose_max_volume_notice ||= begin
              s = Lib_::EN_number[ volume_a.length ]
              @err.puts "(#{ s } is the max number of -v.)"
              true
            end
          end
        end

        op.on('-l', '--list', 'list the resulting files that match the query (before running reports)') {
          req[:show_files_list] = true }

        req[:show_report] = true
        op.on('-R', '--no-report', "don't actually run the whole report") {
          req[:show_report] = false }

        req
      end
      private :op_common_head

      option_parser do |op|

        op.banner = "#{ hi 'description:' }#{
          } Shows the linecount of each file, longest first. Show percentages
          of max for each file. Will go recursively into directories.
        ".gsub(/^ +/, '')

        req = op_common_head
        req[:count_comment_lines] = true
        req[:count_blank_lines]   = true
        op.on('-C', '--no-comments',
          "don't count lines with ruby-style comments") { req[:count_comment_lines] = false }
        op.on('-B', '--no-blank-lines',
          "don't count blank lines") { req[:count_blank_lines] = false }

        op_common_tail
      end

      aliases :lc, :sloc

      def line_count *paths
        opts = @param_h
        paths.empty? and paths.push('.')
        opts[:paths] = paths
        api_call :line_count
      end

      -> do
        UI = ::Struct.new :out, :err
        def api_call name_i
          @ui ||= UI.new @out, @err
          _const_i = Callback_::Name.via_variegated_symbol( name_i ).
            as_camelcase_const
          _cls = FM_::API::Actions.const_get _const_i, false
          _cls.run @ui, @param_h
        end
        private :api_call
      end.call

      option_parser do |op|
        op.banner = <<-DESC.gsub(/^ +/, '')
          #{ hi 'description:' }#{
          } Experimental report. With all folders one level under <path>,
          for each of them report number of files and total sloc,
          and show them in order of total sloc.
        DESC
        op_common_head
        op_common_tail
      end

      def dirs path=nil
        opts = @param_h
        opts[:path] = path || '.'
        api_call :dirs
      end

      option_parser do |op|

        op.banner = <<-O.gsub( /^ +/, '' )  # #todo
          #{ hi 'description:' }#{
          } just report on the number of files with different extensions,
          ordered by frequency of extension
        O

        req = op_common_head

        req[:git] = true
        op.on('--[no-]git-aware', "be aware of git commit objects,",
          "glob them in to one category (default: #{req[:git]})"
        ) { |x| req[:git] = x }

        req[:group_singles] = true
        op.on('--[no-]group-singles',
          "by default, extensions that occur only once are globbed",
          "together. Use the --no form of this flag to flatten them and",
          "count them inline with the rest (default: #{req[:group_singles]})"
        ) { |x| req[:group_singles] = x }

        op_common_tail
      end

      def ext *paths
        opts = @param_h
        paths.empty? and paths.push('.')
        opts[:paths] = paths
        api_call :ext
      end

    private

      def op_common_tail
        # massive but semi-elegant hack, #goof-on wheel greasing.
        s = command.op.banner
        y = Lib_::Reverse_string_scanner[ s ]
        y << ''
        command.usage y
        y << "\n#{ hi 'options:' }\n" ; nil
      end
    # lost indent

    Lipstick = Lib_::CLI_lipstick[ '+', :green, -> { 160 } ]

    class Lipstick::Class_

      def field_h
        @field_h ||= {
          header: '',
          is_autonomous: true,
          cook: -> col_width_a, seplen do
            # (our rendering function takes a proxy, and the upstream rendering
            # function take a normalized float)
            f = cook_rendering_proc col_width_a, nil, seplen
              # `nil` - use ncurses to determine screen width
            -> scalar_pxy do
              f[ scalar_pxy.normalized_scalar ]
            end
          end
        }
      end
    end

    Client = self  # #tmx-compat
  end
end
