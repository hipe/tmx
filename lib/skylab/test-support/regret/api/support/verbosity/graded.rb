module Skylab::TestSupport::Regret::API

  class Support::Verbosity::Graded < ::Module

    # the verbosity object created by this node is itself a module - it is
    # intended to be an immutable constant that is shared accross your
    # application. (it is a module because it is useful to memoize
    # generated structures as constants under it.) :[#fa-032]

    def self.create grade_i_a  # (leave room for shenanigans by isolating this)
      new grade_i_a
    end

    def initialize grade_i_a
      @a = grade_i_a.dup.freeze
    end

    def self.cli_option_function_for client
      client.instance_exec do
        -> _true do
          @param_h[:verbose_count] ||= 0
          @param_h[:verbose_count] += 1
        end
      end
    end

    def parameter
      P_
    end
    P_ = [ :verbose_count, :normalizer, true ].freeze

    def enhance_action_class kls
      f = build_normalizer_function
      kls.class_exec do
        method_defined? :normalize_verbose_count and fail "sanity"
        define_method :normalize_verbose_count, &f
      end
      nil
    end

    def build_normalizer_function
      lvl_a = @a ; len = lvl_a.length ; build_vtuple = get_ivar_a = nil
      f = -> y, x, yes do
        x ||= 1
        if len < x
          @err.puts "(verbosity level #{ len } is the highest. #{
            }ignoring #{ x - len } of the verboses.)"
          x = len
        end
        vtuple = build_vtuple[] ; ivar_a = get_ivar_a[]
        x.times do |i|
          vtuple[ lvl_a.fetch i ] = true
          instance_variable_set ivar_a.fetch( i ), true
        end
        ( len - 1 ).downto( x ) do |i|
          instance_variable_set ivar_a.fetch( i ), false
        end
        @vtuple = vtuple
        yes[ x ]
        true
      end
      build_vtuple = -> { vtuple_class.new }
      get_ivar_a = -> { ivar_a }
      f
    end
    private :build_normalizer_function

    def vtuple_class
      if ! const_defined? :Vtuple_, false
        const_set :Vtuple_, ::Struct.new( * @a )
      end
      const_get :Vtuple_, false
    end
    private :vtuple_class

    def ivar_a
      @ivar_a ||= @a.map { |i| "@do_verbose_#{ i }".intern }.freeze
    end
    private :ivar_a

  end
end
