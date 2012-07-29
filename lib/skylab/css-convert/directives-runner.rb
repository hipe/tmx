module Skylab::CssConvert
  class DirectivesRunner
    include CssConvert::SubClient::InstanceMethods
    def run directives_sexp
      mod = self.class.to_s.match(/\A(.+[^:])::[^:]+\Z/)[1]
      cls = directives_sexp.node_name.to_s.gsub(/([a-z])_([a-z])/) do
        "#{$1}#{$2.upcase}" end.sub(/\A([a-z])/){ $1.upcase }
      c = mod.split('::').inject(Object){|m,n| m.const_get(n)}.const_get(cls)
      c.new(request_runtime, directives_sexp).run
    end
  end
  class MergeStatement
    include CssConvert::SubClient::InstanceMethods
    def initialize request_runtime, sexp
      self.request_runtime = request_runtime
      @sexp = sexp
    end
    def run
      left, right = @sexp[:styles_in_files].children(:left, :right)
      if @sexp[:in_the_folder]
        p = @sexp[:in_the_folder][:path]
        [left, right].each { |x| x.replace("#{p}/#{x}") }
      end
      lp = css_parser.parse_file(left)
      rp = css_parser.parse_file(right)
      emit(:info, "IMPLEMENT ME merge")
    end
  private
    def css_parser
      @css_parser ||= CssConvert::CssParser.new request_runtime
    end
  end
end
