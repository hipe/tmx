module Skylab::CSS_Convert

  class Directives__::MergeStatement

    include Core::SubClient_::InstanceMethods

    def initialize request_client, sexp
      super(request_client)
      @sexp = sexp
    end

    attr_reader :sexp

    def execute
      left, right = @sexp[:styles_in_files].children(:left, :right)
      if @sexp[:in_the_folder]
        p = @sexp[:in_the_folder][:path]
        [left, right].each { |x| x.replace("#{p}/#{x}") }
      end
      b = -> o do
        o.on_file_not_found do |pn, e|
          pn or fail "where is pn?"
          send_error_string "this wasn not found : #{ escape_path pn } which was a #{ e }"
        end
      end
      _lp = css_parser.parse_file(left, &b)
      _rp = css_parser.parse_file(right, &b)
      send_info_message "IMPLEMENT ME merge"
    end

  private

    def css_parser
      @css_parser ||= Home_::CSS_::Parser.new request_client
    end
  end
end
