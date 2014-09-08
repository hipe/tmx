module Skylab::CssConvert
  class Directives::MergeStatement
    include Core::SubClient::InstanceMethods
    def invoke
      left, right = @sexp[:styles_in_files].children(:left, :right)
      if @sexp[:in_the_folder]
        p = @sexp[:in_the_folder][:path]
        [left, right].each { |x| x.replace("#{p}/#{x}") }
      end
      b = -> o do
        o.on_file_not_found do |pn, e|
          pn or fail "where is pn?"
          error "this wasn not found : #{ escape_path pn } which was a #{ e }"
        end
      end
      _lp = css_parser.parse_file(left, &b)
      _rp = css_parser.parse_file(right, &b)
      send_info_message "IMPLEMENT ME merge"
    end
    attr_reader :sexp
  private
    def css_parser
      @css_parser ||= CssConvert::CSS::Parser.new request_client
    end
    def initialize request_client, sexp
      super(request_client)
      @sexp = sexp
    end
  end
end
