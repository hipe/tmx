require File.expand_path('../common', __FILE__)
require 'skylab/face/open2'
require 'pathname'
require 'stringio'
require 'strscan'

module Skylab::FileMetrics

  class API::Ext
    extend API::CommonModuleMethods
    include API::CommonInstanceMethods
    include Skylab::Face::Open2
    GitObjectRe = /\A[0-9a-f]{38,40}\z/
    def run
      pats = []
      @req[:git] and pats.push([GitObjectRe, 'git object'])
      pats.push([/\A\./, '(dotfiles)'])
      @req[:verbose] and PP.pp(@req, @ui.err)
      files = find_files
      extension_counts = Hash.new { |h, k| h[k] = { :count => 0, :extension => k } }
      files.each do |file|
        pn = Pathname.new(file)
        ext = pn.extname.to_s
        # normalize filenames without extensions but that are of the same type, using a regex
        ext.empty? && (ext = ((pat = pats.detect{ |p| p[0] =~ pn.basename.to_s }) ? pat[1] : pn.basename.to_s))
        extension_counts[ext][:count] += 1
      end
      count = Models::Count.new('Extension Counts')
      singles = nil
      extension_counts.values.each do |data|
        if @req[:group_singles] and 1 == data[:count]
          singles ||= []
          singles.push data[:extension]
        else
          count.add_child Models::Count.new("*``#{data[:extension]}", data[:count])
        end
      end
      if singles
        grouped_singles = true
        count.add_child Models::Count.new("(assorted)", singles.size)
      end
      if count.children.nil?
        @ui.err.puts "(no extenstions)"
      else
        massage count
        render_table count, @ui.err
      end
      if singles
        if grouped_singles
          @ui.err.puts <<-HERE.gsub(/\n */, ' ').strip
            (assorted were: #{singles * ', '}.)
          HERE
        else
          @ui.err.puts <<-HERE.gsub(/\n */, ' ').strip
            (The following occured only once and were not counted in the final tally:
            #{singles * ', '}.)
          HERE
        end
      end
    end

    # this does things wierdly as an experiment for massively progressive output
    def find_files
      cmd = build_find_command.to_s
      @req[:show_commands] and @ui.err.puts(cmd)
      buff = StringIO.new
      open2(cmd) do |op|
        op.err { |s| fail("not expecting stderr output from find cmd: #{s.inspect}.") }
        if @req[:verbose]
          op.out { |s| buff.write(s); @ui.err.write(s) }
        else
          op.out { |s| buff.write(s) }
        end
      end
      s = StringScanner.new(buff.rewind && buff.read)
      files = []
      s.skip(/\n+/)
      while line = s.scan(/[^\n]+/)
        files.push line
        s.skip(/\n+/)
      end
      files
    end

    def build_find_command
      Models::FindCommand.build do |f|
        f.paths = @req[:paths]
        f.skip_dirs = @req[:exclude_dirs]
        f.names = @req[:include_names]
        f.extra = '-not -type d'
      end
    end

    def massage count
      return unless count.children?
      count.sort_children_by! { |c| -1 * c.count }
      total = count.total.to_f
      max = count.children.map(&:count).max.to_f
      count.children.each do |o|
        o.set_field(:total_share, o.count.to_f / total)
        o.set_field(:max_share, o.count.to_f / max)
      end
      count.display_summary_for(:name) { "Total:" }
      count.display_total_for(:count) { |d| "%d" % d }
      nil
    end

    def render_table count, out
      count.children? or return
      labels = {
        :count => 'Num Files'
      }
      percent = lambda { |v| "%0.2f%%" % (v * 100) }
      filters = {
        :total_share => percent,
        :max_share => percent
      }
      _render_table count, out, labels, filters
    end
  end
end
