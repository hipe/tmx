module Skylab::CssConvert
  class Directives::MergeStatement
    include My::Headless::SubClient::InstanceMethods
    def invoke
      left, right = @sexp[:styles_in_files].children(:left, :right)
      if @sexp[:in_the_folder]
        p = @sexp[:in_the_folder][:path]
        [left, right].each { |x| x.replace("#{p}/#{x}") }
      end
      b = ->(o) do
        o.on_file_not_found do |pn, e|
          error("this wasn not found : #{pn.pretty} which was a #{e}")
        end
      end
      lp = css_parser.parse_file(left, &b)
      rp = css_parser.parse_file(right, &b)
      emit(:info, "IMPLEMENT ME merge")
    end
    attr_reader :sexp
  protected
    def css_parser
      @css_parser ||= CssConvert::CSS::Parser.new request_runtime
    end
    def initialize request_runtime, sexp
      super(request_runtime)
      @sexp = sexp
    end
  end
end
