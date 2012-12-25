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
      on_info = on_load_parser_info
      on_info ||= -> e do
        if verbose
          info "#{ em '-->' } #{ gsub_path_hack e.to_s }"
        end
      end

      TreetopTools::Parser::Load.new( self,
        -> o do
          o.force_overwrite! if force
          o.generated_grammar_dir '../../../tmp'
          o.root_for_relative_paths TanMan.dir_path
          o.treetop_grammar 'statement/parser/statement.treetop'
        end,
        -> o do                   # this might get [#046]'d
           o.on_info(& on_info)
           o.on_error { |e| fail "failed to load grammar: #{ e }" }
        end
      ).invoke
    end

    def parse_words words_arr, opts=nil
      parse_string words_arr.join(' '), opts
    end

    def parser_failure # might get dried : DRY #watch [#ttt-002]
      res = nil
      begin
        # parser.failure_reason, parser.failure_line, parser.failure_column
        failures = parser.terminal_failures
        failures.empty? and break
        a = ['Expected']
        aa = failures.map(& :expected_string).uniq
        a << (or_ aa.map(& :inspect))
        a << "at column #{ parser.failure_column }"
        a << parser_failure_input_excerpt # we are ingnoring failure_line
        msg = a.join ' '
        res = error msg
      end while nil
      res
    end

    def parser_failure_input_excerpt
      res = nil
      if 0 == parser.failure_index
        md = parser.input.match( # match 'token [ space token ]'
          /\A(?<first>[^[:space:]]*(?:[[:space:]]+[^[:space:]]+)?)
             (?<rest>.+)?/x
        )
        res = "at \"#{ md[:first] }#{ '..' if md[:rest] }\""
      else
        _s = parser.input[ parser.index...parser.failure_index ]
        md = _s.match(
          /(?<rest>[[:space:]])?
           (?<last>(?:[^[:space:]]+[[:space:]]+)?[^[:space:]]*)\z/x
        )
        res = "after \"#{ '..' if md[:rest] }#{ md[:last] }\""
      end
      res
    end
  end
end
