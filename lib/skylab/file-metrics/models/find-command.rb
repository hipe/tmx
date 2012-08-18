module Skylab::FileMetrics
  class Models::FindCommand
    include Common::PathTools::InstanceMethods
    def initialize; end
    attr_accessor :paths, :skip_dirs, :names, :extra
    def self.build &block
      fc = new
      yield fc
      fc
    end
    def render
      parts = ["find"]
      parts.push @paths.map { |p| escape_path(p) }.join(' ')
      if @skip_dirs && @skip_dirs.any?
        paths = @skip_dirs.map{ |p| escape_path(p) }
        parts.push '-not \( -type d \( -mindepth 1 -a'
        parts.push paths.map{ |p| " -name '#{p}'" }.join(' -o')
        parts.push "\\) -prune \\)"
      end
      @extra and parts.push @extra
      if @names && @names.any?
        paths = @names.map{ |p| escape_path(p) }
        _ = @names.map{ |p| " -name '#{escape_path(p)}'"}.join(' -o')
        parts.push "\\(#{_} \\)"
      end
      parts.join(' ')
    end
    alias_method :to_s, :render
  end
end
