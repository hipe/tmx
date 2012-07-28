module Skylab::CssConvert
  class DirectivesRunner
    def initialize(ctx)
      @c = ctx
    end
    def run directives_sexp
      mod = self.class.to_s.match(/\A(.+[^:])::[^:]+\Z/)[1]
      cls = directives_sexp.node_name.to_s.gsub(/([a-z])_([a-z])/) do
        "#{$1}#{$2.upcase}" end.sub(/\A([a-z])/){ $1.upcase }
      c = mod.split('::').inject(Object){|m,n| m.const_get(n)}.const_get(cls)
      c.new(@c, directives_sexp).run
    end
  end
  class MergeStatement
    def initialize ctx, sexp
      @c = ctx
      @sexp = sexp
    end
    def run
      left, right = @sexp[:styles_in_files].cx_slice(:left, :right)
      if @sexp[:in_the_folder]
        p = @sexp[:in_the_folder][:path]
        [left, right].each { |x| x.replace("#{p}/#{x}") }
      end
      lp = css_parser.parse_file(left)
      # rp = css_parser.parse_file(right)
      # @c.out.puts("skipping this for now in directives runner")
    end
  private
    def css_parser
      @css_parser ||= begin
        require ROOT + '/css-parser'
        CssParser.new(@c)
      end
    end
  end
end
