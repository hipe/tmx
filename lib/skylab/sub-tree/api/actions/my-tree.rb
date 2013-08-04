module Skylab::SubTree

  class API::Actions::My_Tree

    MetaHell::FUN::Fields_[ :client, self, :method, :absorb_iambic,
      :field_i_a, [ :expression_agent, :program_name, :param_h,
                    :upstream, :paystream, :infostream ] ]
    def absorb * a
      absorb_iambic( * a )
      self
    end

    VERBOSE_SET_A = [ 'file command', 'lines' ].freeze
    VSA_ = VERBOSE_SET_A.map { |str| str[ 0 ] }.freeze

    Face = SubTree::Services::Face

    Face::API::Params_[ :client, self,

      :meta_param, :plugin,

      :param, :path_a, :arity, :one_or_more,

      :param, :file, :arity, :zero_or_one,
        :desc, -> y do
          y << "instead of #{ par :path }, get tree paths from #{
            }file, one per line"
        end,

      :param, :line_count, :arity, :zero_or_one, :argument_arity,
        :zero, :plugin, :desc, "as reported by wc, affixed as metadata",

      :param, :mtime, :arity, :zero_or_one, :argument_arity, :zero,
        :plugin, :desc, "if ordinary file, display humanized mtime",

      :param, :pattern, :arity, :zero_or_one, :argument_arity, :one,
        :single_letter, 'P', :desc, 'meh',

      :param, :verbose, :arity, :zero_or_more, :argument_arity, :zero,
        :argument_string, " [#{ VSA_ * '|' }]", :desc, -> y do
          hilite_first = -> s { "#{ kbd s[0] }#{ s[1..-1] }" }

          y << "verbose #{ VERBOSE_SET_A.map( & hilite_first ) * ', ' } #{
           }(any permutation)"
        end,
    ]

    def write_option_parser_to o

      Face::CLI::API_Integration::OP_[ :op, o, :param_h, @param_h,
        :field_box, self.class::FIELDS_, :expression_agent, @expression_agent ]

      o.separator ''

      @expression_agent.instance_exec do
        o.separator "  (it can also read paths from STDIN instead of #{
          }#{ par :file } or #{ par :path })"
      end

      nil
    end

    def absorb_params *a
      0.step( a.length - 1, 2 ).each do |i|
        @param_h[ a[ i ] ] = a[ i + 1 ]
      end
      self  # allow chaining
    end

    define_method :flush, Face::API::Normalizer_::Flush_method_

  private

    def initialize
      @exit_status_p = nil
    end

    def execute
      begin
        r = resolve_upstream or break
        t = self.class::Traversal_.new :out_p, @paystream.method( :puts )
        while (( line = @upstream.gets ))
          t.puts line
        end
        @upstream.tty? or @upstream.close
        t.flush_notify
        @exit_status_p and mention_exit_status
        r = true
      end while nil
      r
    end

    def resolve_upstream
      have = [ ]
      ( ! @upstream || @upstream.tty? ) or have << :stdin
      @path_a[ 0 ] and have << :path
      @file and have << :file
      case have.length
      when 0 ; bork "no input"
      when 1 ; i = @resolve_upstream_from_i = have.fetch 0
             ; send RUFH_.fetch( i )
      else   ; bork -> do
          "can't read input from#{ both have } #{
            }#{ and_ have.map( & method( :par ) ) }"
        end
      end
    end
    RUFH_ = { stdin: :resolve_upstream_from_stdin,
               path: :resolve_upstream_from_path,
               file: :resolve_upstream_from_file }.freeze

    def resolve_upstream_from_stdin
      true
    end

    def resolve_upstream_from_file
      @upstream = ::File.open @file, 'r'
      true
    end

    def resolve_upstream_from_path
      cmd = SubTree::Find_Command_.new
      cmd.concat_paths @path_a
      if (( cmd_s = cmd.string ))
        @verbose and 1 <= @verbose and mention cmd_s
        i, o, e, t = SubTree::Services::Open3.popen3 cmd_s
        i.close
        if (( s = e.read )) && '' != s
          o.close
          bork "#{ s.chomp } (exitstatus #{ t.value.exitstatus })"
        else
          @exit_status_p = -> { t.value.exitstatus }
          e.close
          @upstream = o
          true
        end
      else
        false
      end
    end

    def mention_exit_status
      if @exit_status_p and @verbose and 1 <= @verbose
        mention "(exitstauts #{ @exit_status_p[] })"
      end
    end

    #  ~ abstraction candidates ~

    def bork x
      mention x
      false
    end

    def mention x
      p = x.respond_to?( :call ) ? x : -> { x }
      msg = expression_agent.calculate p
      @infostream.puts msg
      nil
    end

    def expression_agent
      @expression_agent ||= self.class::EXPRESSION_AGENT_
    end
  end
end
