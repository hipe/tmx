module Skylab::TestSupport

  class Slowie

    class Operations::Cover

      def initialize
        o = yield
        @_argument_scanner = o.argument_scanner
        @_emit = o.listener
      end

      def execute
        if @_argument_scanner.no_unparsed_exists
          __express_furloughed
        else
          self._COVER_ME_extra_arguments
        end
      end

      def __express_furloughed

        @_emit.call :error, :expression, :furloughed do |y|
          y << "\"cover\" is furloughed, probably won't be on for a while (is [#012])"
        end

        UNABLE_
      end

        if false

        # assume coverage has been requested

        def initialize resources, & oes_p

          _pn = oes_p.call :for_plugin, :program_name

          @command_name = "(XX #{ _pn } XX)"
          @serr = resources.serr
          @stateful_matcher = Stateful_Matcher___.new resources, & oes_p

        end

        def ARGV= x
          @stateful_matcher.ARGV = x
        end

        def ARGV_coverage_switch_index= x
          @stateful_matcher.ARGV_coverage_switch_index = x
        end

        def execute
          _ok = @stateful_matcher.normalize
          _ok && __start_simplecov
        end

        def __start_simplecov

          require 'simplecov'  # $VERBOSE
          sc = ::SimpleCov
          sc.command_name @command_name
          sc.add_filter( & @stateful_matcher.handle_yes_or_no_via_vendor_file )
          special_x = sc.start
          if special_x.nil?
            @serr.puts "(coverage appears to have started successfully)"
            ::Kernel.at_exit( & method( :__at_exit ) )
            ACHIEVED_
          else
            __TODO_when_never_before_seen_result_of_starting_coverage special_x
          end
        end

        def __at_exit
          @serr.puts '(coverage plugin has seen the exit)'
          nil
        end
        end  # if false

        if false
        class Stateful_Matcher___

          # decide whether or not you want each file (whose paths are each
          # passed sometimes many times) based on the sidesystem it appears
          # in. cache this decision.

          def initialize resources, & oes_p
            @on_event_selectively = oes_p
            @serr = resources.serr
          end

          attr_writer :ARGV, :ARGV_coverage_switch_index

          def normalize

            self._HELLO  # change below to use sidesys_inference_stream_proc

            @root_path = @on_event_selectively.call :for_plugin, :r_oot_directory_path
            d_a = ( 0 ... @ARGV_coverage_switch_index ).to_a
            d_a.concat ( @ARGV_coverage_switch_index + 1 ... @ARGV.length ).to_a

            h = {}
            ::Dir[ "#{ @root_path }/*" ].each do | path |  # :+[#sl-118] (3 of N)
              h[ ::File.basename path ] = path
            end

            cover_these = []
            extra_a = nil

            d_a.each do | d |
              token = @ARGV.fetch d
              if h.key? token
                cover_these.push token
              else
                ( extra_a ||= [] ).push token
              end
            end

            @simple_sidesystem_index = h

            if extra_a
              __when_extra extra_a
            else

              # mutate ARGV now before generated "canary" parser sees switch

              @ARGV[ @ARGV_coverage_switch_index, 1 ] = EMPTY_A_

              __when_normal cover_these
            end
          end

          def __when_extra extra_a

            coverage_moniker = @ARGV.fetch @ARGV_coverage_switch_index

            h = @simple_sidesystem_index

            @on_event_selectively.call :error, :expression do | y |

              _middle_two = if 3 > h.length
                h.keys
              else
                d = h.length / 2
                ks = h.keys
                [ ks[ d - 1 ], ks[ d ] ]
              end

              _s_a = _middle_two.map do | s |
                s.inspect
              end

              _s_a_ = extra_a.map do | s |
                s.inspect
              end

              y << "`#{ coverage_moniker }` can only work with a limited #{
                }set of arguments."

              y << "you can only use *full* names of sidesystems (#{
                }#{ _s_a * ', ' } etc)."

              y << "this/these argument(s)/options(s) cannot be used: #{
                }#{ _s_a_ * ', ' }"

            end
            UNABLE_
          end

          def __when_normal cover_these

            cache_h = {}

            do_want = __decide_if_want cover_these

            @etc_p = -> vendor_source_file do

              cache_h.fetch vendor_source_file.filename do | path |
                cache_h[ path ] = do_want[ path ]
              end
            end
            ACHIEVED_
          end

          def handle_yes_or_no_via_vendor_file
            @etc_p
          end

          def __decide_if_want cover_these

            yes = ::Hash[ cover_these.map { | s | [ s, true ] } ]

            common_head = "#{ @root_path }#{ SEP__ }"
            common_head_d = common_head.length

            -> path do

              if common_head == path[ 0, common_head_d ]

                d_ = path.index SEP__, common_head_d
                if d_

                  ss_name = path[ common_head_d .. d_ - 1 ]

                  if yes[ ss_name ]
                    DO_WANT__
                  else
                    @serr.puts "(skipping per sidesystem: #{ path })"
                    DO_NOT_WANT__
                  end
                else
                  @serr.puts "(STRANGER: #{ path })"
                  DO_NOT_WANT__
                end
              else
                @serr.puts "(stranger: #{ path })"
                DO_NOT_WANT__
              end
            end
          end
        end  # stateful matcher
        end  # if false

      if false
      # ~ as plugin (we have to re-write looking like a plugin because [#002])

      class << self
        alias_method :new_via_plugin_identifier_and_resources, :new
        private :new
      end  # >>

      def initialize _plugin_idx, _resources, & oes_p
      end

      def each_reaction
      end

      def each_capability
      end

      # ~ lots of these are duplicated because [#002]

      ACHIEVED_ = true
      DO_NOT_WANT__ = true  # sic
      DO_WANT__ = false  # sic
      EMPTY_A_ = []
      SEP__ = ::File::SEPARATOR
      UNABLE_ = false
      end  # if false

    end  # this operation
  end  # slowie
end
