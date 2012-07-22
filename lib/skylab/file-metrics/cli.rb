require_relative 'core'

module Skylab::FileMetrics
  class CLI < ::Skylab::Face::Cli
    # lost indent
      COMMON = lambda do |op, req|

        req[:exclude_dirs] = ['.*']

        op.on('-D', '--exclude-dir DIR',
          'Folders whose basename match this pattern will not be',
          'descended into.  It can be specified multiple times',
          'with multiple patterns to narrow the search.',
          'If not provided, the default is to skip folders whose',
          "name starts with a '.' (period).  To include such",
          'dirs, specify "--exclude-dirs=[]" the first time you',
          'use this option in the command.  (it has the effect',
          'of clearing the "blacklist" of directories to skip)') do |dir|
            if '[]' == dir
              req[:exclude_dirs].clear
            else
              req[:exclude_dirs].push dir
            end
        end


        req[:include_names] = []

        op.on('-n', '--name NAME',
          "e.g. --name='*.rb'.  When present, this limits the",
          'files analyzed to the ones whose basename matches',
          'this pattern. It can be specified multiple times to',
          'add multiple filename patterns, which will broaden',
          'the search.  You should use single quotes to avoid',
          'shell expansion.',
          ' ',
          'When PATH is a file, this option is ignored.'
        ) do |pattern|
          req[:include_names].push pattern
        end

        req[:verbose] = false
        op.on('-v', '--verbose',
          'e.g. show the generated {find|wc} commands we (would) use, etc') do
          req[:verbose] = true
          req[:show_commands] = true
        end

        op.on('-l', '--list', 'list the resulting files that match the query (before running reports)') {
          req[:show_files_list] = true }

        req[:show_report] = true
        op.on('-R', '--no-report', "don't actually run the whole report") {
          req[:show_report] = false }
      end

      o :"line-count", :"lc", :"sloc" do |op, req|
        syntax "#{invocation_string} [opts] [PATH [PATH [...]]]"
        op.banner = "
          Shows the linecount of each file, longest first. Show
          percentages of max for each file.   Will go recursively
          into directories.\n#{usage_string}
        ".gsub(/^ +/, '')

        COMMON.call(op, req)

        req[:count_comment_lines] = true
        req[:count_blank_lines]   = true
        op.on('-C', '--no-comments',
          "don't count lines with ruby-style comments") { req[:count_comment_lines] = false }
        op.on('-B', '--no-blank-lines',
          "don't count blank lines") { req[:count_blank_lines] = false }
      end

      def line_count opts, *paths
        paths.empty? and paths.push('.')
        opts[:paths] = paths
        require File.expand_path('../api/line-count', __FILE__)
        API::LineCount.run(self, opts)
      end

      o :"dirs" do |op, req|
        syntax "#{invocation_string} [opts] [<path>]"
        op.banner = <<-DESC.gsub(/^ +/, '')
          Experimental report.  With all folders one level under <path>,
          for each of them report number of files and total sloc,
          and show them in order of total sloc and percent of max
        DESC
        COMMON.call(op, req)
      end

      def dirs opts, path=nil
        opts[:path] = path || '.'
        require File.expand_path('../api/dirs', __FILE__)
        API::Dirs.run(self, opts)
      end


      o :"ext" do |op, req|

        syntax "#{invocation_string} [opts] [<path> [<path> [..]]]"

        op.banner = <<-DESC.gsub(/^ +/, '')
          #{hi 'description:'} just report on the number of files with different extensions,
          ordered by frequency of extension
          #{usage_string}
          #{hi 'options:'}
        DESC

        COMMON.call(op, req)

        req[:git] = true
        op.on('--[no-]git-aware', "be aware of git commit objects,",
          "glob them in to one category (default: #{req[:git]})"
        ) { |x| req[:git] = x }

        req[:group_singles] = true
        op.on('--[no-]group-singles', "by default, extensions that occur only once",
          "are globbed together. Use this flag ",
          "to include them in the main table. (default: #{req[:group_singles]})"
        ) { |x| req[:group_singles] = x }

      end

      def ext opts, *paths
        paths.empty? and paths.push('.')
        opts[:paths] = paths
        require File.expand_path('../api/ext', __FILE__)
        API::Ext.run(self, opts)
      end
    # lost indent
  end
end
