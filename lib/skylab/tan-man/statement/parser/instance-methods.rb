module Skylab::TanMan

  module Statement::Parser::InstanceMethods
    include TanMan::Parser::InstanceMethods

    ENTITY_NOUN_STEM = 'statement'

  protected

    opts_struct = ::Struct.new :force
    define_method :absorb_parse_opts! do |o_h|
      o = opts_struct.new
      o_h.each { |k, v| o[k] = v }
      if o[:force]
        self.force ||= force # hehe sometimes this option takes a long round
                             # trip back to where it originated (an api
                             # action)
      end
      true                   # semantic
    end

    def load_parser_class
      f = on_load_parser_info
      f ||= -> e do
        info "#{ em '-->' } #{ gsub_path_hack e.to_s }"
      end

      TreetopTools::Parser::Load.new(
        -> o do
          o.force_overwrite! if force
          o.generated_grammar_dir '../../../tmp'
          o.root_for_relative_paths TanMan.dir_path
          o.treetop_grammar 'statement/parser/statement.treetop'
        end,
        -> o do                   # this might get [#046]'d
           o.on_info(& f)
           o.on_error { |e| fail "failed to load grammar: #{ e }" }
        end
      ).invoke
    end

    def parse_words words_arr, opts=nil
      parse_string words_arr.join(' '), opts
    end

    def parser_failure
      fail 'TEST ME - THE BELOW IS NOT YET COVERED BY TESTS' # #TODO (and take returns out)
      # failure_reason, failure_line, failure_column
      (a = parser.terminal_failures).empty? and return nil
      _msg = [ 'Expected',
        (1 == a.length ?
          a.first.expected_string.inspect :
          "one of #{a.map { |f| f.expected_string.inspect }.uniq.join(', ')}"
        ),
        "at column #{parser.failure_column}", # we are ingnoring failure_line
        parser_failure_input_excerpt
       ].join(' ')
       error(_msg)
    end

    def parser_failure_input_excerpt
      if 0 == parser.failure_index
        md = parser.input.match( # match 'token [ space token ]'
          /\A(?<first>[^[:space:]]*(?:[[:space:]]+[^[:space:]]+)?)
             (?<rest>.+)?/x
        )
        "at \"#{md[:first]}#{'..' if md[:rest]}\""
      else
        _s = parser.input[parser.index...parser.failure_index]
        md = _s.match(
          /(?<rest>[[:space:]])?
           (?<last>(?:[^[:space:]]+[[:space:]]+)?[^[:space:]]*)\z/x
        )
        "after \"#{'..' if md[:rest]}#{md[:last]}\""
      end
    end
  end
end
