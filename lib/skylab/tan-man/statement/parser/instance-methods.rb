module Skylab::TanMan

  module Statement::Parser::InstanceMethods

    include TanMan::Parser::InstanceMethods

  private

    # (we used to use the below for --force but we do it better now)
    define_method :absorb_parse_opts! do |o_h| # #compat ttt
      if o_h.any?
        raise ::ArgumentError.new 'this takes no opts'
      end
      true                        # important
    end

    def produce_parser_class  # #hook-out for [ttt]
      on_info_p = receive_parser_loading_info_p
      on_info_p ||= -> e do
        if verbose
          send_info_string "#{ em '-->' } #{ gsub_path_hack e.to_s }"
        end
      end

      Headless::Services::TreetopTools::Parser::Load.new( self,
        -> o do
          o.force_overwrite! if rebuild_tell_grammar
          o.generated_grammar_dir '../../../tmp'
          o.root_for_relative_paths TanMan.dir_pathname
          o.treetop_grammar 'statement/parser/statement.treetop'
        end,
        -> o do                   # this might get [#046]'d
           o.on_info on_info_p
           o.on_error { |e| fail "failed to load grammar: #{ e }" }
        end
      ).invoke
    end

    def parse_words words_arr, opts=nil
      parse_string words_arr.join(' '), opts
    end

    def when_parse_failure  # might get dried : DRY #watch [#ttt-002]
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

    def receive_parser_error_message s
      error s
    end

    def entity_noun_stem
      ENTITY_NOUN_STEM__
    end

    ENTITY_NOUN_STEM__ = 'statement'.freeze

  end
end
