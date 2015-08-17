module Skylab::CSS_Convert

  class Directives__::MergeStatement

    def initialize client, sexp

      @_client = client
      @sexp = sexp
    end

    attr_reader :sexp

    def execute

      left, right = @sexp[:styles_in_files].children(:left, :right)

      if @sexp[:in_the_folder]
        p = @sexp[:in_the_folder][:path]
        [left, right].each { |x| x.replace("#{p}/#{x}") }
      end

      self._THIS_IS_WHAT_YOU_DO_AFTER_YOU_PARSE_CSS

      b = -> o do
        o.on_file_not_found do |pn, e|
          pn or fail "where is pn?"
          send_error_string "this wasn not found : #{ escape_path pn } which was a #{ e }"
        end
      end

      css_parser = Home_::CSS_::Parser.new @_client

      _lp = css_parser.parse_file(left, &b)
      _rp = css_parser.parse_file(right, &b)

      send_info_message "IMPLEMENT ME merge"
    end
  end
end
