#!/usr/bin/env ruby -w

# (see also spots marked [#002]. at writing all coverage is borked.)

if __FILE__ == $PROGRAM_NAME

  # for fun and regressability we allow this to be run as a standalone script
  # as well as from within our [br]-powered API. below hacks accomodate this.

  is_invocation_of_one_off = true

  module Skylab
    module TestSupport
      Home_ = self
      module API
        Models_ = ::Module.new
        Brazen_ = ::Object.new
        def Brazen_::Model
          o = ::Object.new
          def o.entity( * )
          end
          o
        end
      end
    end
  end
end

module Skylab::TestSupport

  module API

    # a fun one-off for using simplecov in ad-hoc scenarios. if you have
    # some ruby that can be run by loading one file and processing some
    # argv (probably all ruby), you can use this script to load it, while
    # indicating explicitly which files you would like to get coverage
    # information on.

    # this is for ad-hoc scenarios (like debugging something tricky) and not
    # for typical coverage measurement of a test or test suite. for such
    # standard use, please see the simplecov gem's README.md

    module Models_
    end

    class Models_::Simplecov

      Actions = ::Module.new

      class Actions::Cover

        Actions = nil

        class << self

          def is_branch
            false
          end

          def adapter_class_for _
            NIL_
          end

          def is_promoted
            true
          end

          def model_class
            Home_::Models_::Simplecov
          end

          def name_function
            @__nf__ ||= Common_::Name.via_module self
          end

          alias_method :define, :new
          undef_method :new
        end  # >>

        if false
        Brazen_::Modelesque.entity self,
          :required, :argument_arity, :one_or_more, :property, :arg
        end

        def initialize
          yield self
        end

        attr_writer(
          :argv,
          :invocation_string_array,
          :serr,
          :sout,
        )

        def _WAS_initialize _boundish, & oes_p

          @on_event_selectively = oes_p
        end

        def after_name_symbol
          nil
        end

        def is_visible
          true
        end

        def name
          self.class.name_function
        end

        def description_proc
          self._WAS_look
          [ 'ya sure whatever' ]
        end

        def accept_parent_node x
          @__NOT_USED_the_kernel_again__ = x
          nil
        end

        def bound_call_against_argument_scanner st, & oes_p

          :arg == st.gets_one or raise ::ArgumentError
          a = st.gets_one
          st.unparsed_exists and raise ::ArgumentError

          # begin hacky fix

          a == ::ARGV or self._SANITY
          a.object_id == ::ARGV.object_id and self._THIS_IS_FIXED
          a = ::ARGV

          # end hacky fix

          @argv = a

          Common_::BoundCall.via_receiver_and_method_name self, :execute
        end

        def execute
          if @argv.length.zero?
            _usage
          elsif 1 == @argv.length && /\A-(?:h|-help)\z/ =~ @argv.first
            __help
          else
            __nonzero_argv
          end
        end

        def __help
          _usage
        end

        def _usage

          @serr.puts "usage: #{ _program_name } #{
            }[ <white-path-fragment> [ <white-path-fragment> [..] ] -- ] <a-ruby-file>"

          SUCCESS_EXITSTATUS__
        end

        def __nonzero_argv
          ok = __resolve_matcher
          ok &&= __validate_remaining_ARGV
          ok && __via_matcher_execute
        end

        def __resolve_matcher
          idx = @argv.index DOUBLE_DASH___
          if idx
            __resolve_matcher_via_parse_argv idx
          else
            @matcher = Mock_Matcher___.new
            ACHIEVED_
          end
        end

        DOUBLE_DASH___ = '--'

        class Mock_Matcher___
          def filter x
            false
          end
        end

        def __resolve_matcher_via_parse_argv idx
          white_file_frags = @argv[ 0, idx ]
          if white_file_frags.length.zero?
            @serr.puts "(empty whitelist, aborting)"
            _invite
          else
            @argv[ 0 .. idx ] = EMPTY_A_
            @matcher = Caching_Matcher___.new white_file_frags
            ACHIEVED_
          end
        end

        class Caching_Matcher___

          def initialize white_frag_list

            cache_h = {}

            @p = -> vendor_file do

              cache_h.fetch vendor_file.filename do | path |

                skip_this = true

                white_frag_list.each do | frag |
                  if path.include? frag
                    skip_this = false
                    break
                  end
                end

                cache_h[ path ] = skip_this
              end
            end
          end

          def filter x
            @p[ x ]
          end
        end

        def __validate_remaining_ARGV
          if @argv.length.zero?
            @serr.puts "need some args after `--`"
            _invite
          else
            ACHIEVED_
          end
        end

        def __via_matcher_execute  # assume nonzero length argv

          require 'simplecov'

          # we assume that the first arg element is a loadable path. we shift
          # it off so that the remaining argv attempts to mimic the argv that
          # the script would have seen if it were invoked with ruby or as an
          # exeuctable.

          @serr.puts "(#{ _program_name } about to run: #{ @argv * SPACE_ })"

          path = @argv.shift

          ::SimpleCov.command_name "#{ ::File.basename path } (skylab simplecov)"

          ::SimpleCov.add_filter do | sourcefile |

            # hello
            @matcher.filter sourcefile
          end

          ::SimpleCov.start

          # this kind of sucks: apparently the simplecov hooks into `require`
          # and not `load` (from the looks of it), so if a standalone file
          # itself is what you're covering, we cannot use load, hence it must
          # end with an `.rb`. in other words for now it appears impossible
          # to cover a standalone executable ruby script.

          require ::File.expand_path path
        end

        def _invite
          @serr.puts "try `#{ _program_name } -h` for help."
          UNABLE_
        end

        def _program_name
          @__pn__ ||= "#{ @invocation_string_array * SPACE_ }".freeze
        end
      end

      # ( we need our own because we might be standalone: )

      ACHIEVED_ = true
      SPACE_ = ' '.freeze
      SUCCESS_EXITSTATUS__ = 0
      UNABLE_ = false
    end
  end
end

cls = Skylab::TestSupport::API::Models_::Simplecov::Actions::Cover
if is_invocation_of_one_off

  cls.define do |o|
  o.invocation_string_array = [ $PROGRAM_NAME ]
  o.sout = $stdout
  o.serr = $stderr
  o.argv = ::ARGV
  end.execute
else
  Skylab__Zerk__OneOffs::Test_support_cover = -> * five do  # #[#ze-063.1] mountable one-off
    cls.define do |o|
      o.argv, _, o.sout, o.serr, o.invocation_string_array = five
    end.execute
  end
end
# :+#tombstone: rspec integration (ancient)
