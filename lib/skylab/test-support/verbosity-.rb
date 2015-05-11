module Skylab::TestSupport

  lib_  # load LIB_

  class Verbosity_ < ::Module  # see [#024]

    class << self

      def produce_conf_module grade_i_a
        new grade_i_a
      end

      private :new
    end

    def initialize grade_i_a
      @lvl_a = grade_i_a.dup.freeze
    end

    attr_reader :lvl_a

    def [] mod_x
      wat = Aggregates__.const_get mod_x.metastory.aggregate_exponent, false
      wat[ self, mod_x ]
    end

  Aggregates__ = ::Module.new

  module Aggregates__::CLI_Modality_Client_
    def self.[] vmod, cli_kls
      cli_kls.class_exec do
        include IM_
        if ! const_defined? :Vmod_, false
          const_set :Vmod_, vmod
        end
        nil
      end
    end
  end

  module Aggregates__::CLI_Modality_Client_::IM_
  private
    def verbosity_opt_func
      @verbosity_opt_func ||= begin
        kls = @mechanics.api_services.hot_api_action_class
        kls.mutable_verbosity_story.build_opt_func_for self, 1
      end
    end
    def deincrement_verbosity_opt_func
      @deincrement_verbosity_opt_func ||= begin
        kls = @mechanics.api_services.hot_api_action_class
        kls.mutable_verbosity_story.build_opt_func_for self, -1
      end
    end
  end

  module Aggregates__::API_Action_
    def self.[] vmod, api_action_class
      api_action_class.class_exec do
        if respond_to? :mutable_verbosity_story
          mutable_verbosity_story
        else
          def self.mutable_verbosity_story
            const_get :Mutable_Verbosity_Story_, false
          end
          if const_defined? :Mutable_Verbosity_Story_, false
            const_get :Mutable_Verbosity_Story_, false
          else
            const_set :Mutable_Verbosity_Story_, Mutable_Vstory_.new( vmod,
              self )
          end
        end
      end
    end
  end

  class Aggregates__::API_Action_::Mutable_Vstory_ < ::Module

    def initialize vmod, api_application_class
      @param_i = nil
      @default_level_integer = 1
      @vmod, @api_application_class = vmod, api_application_class
    end

    # `param` - you chose the name, we do the rest.

    def param i
      @param_i and fail "param ame is write once."
      @param_i = i
      [ i, :normalizer,  build_normalizer_proc ]
    end

    def default_level_integer x
      @default_level_integer = x
    end

    def build_opt_func_for command, inc
      param_i = @param_i ; d = @default_level_integer
      command.instance_exec do
        -> _ do
          @param_h[ param_i ] ||= d
          @param_h[ param_i ] += inc
        end
      end
    end

    def build_normalizer_proc
      sty = self
      -> y, x, yes do
        lvl_a = sty.lvl_a ; len = lvl_a.length
        x = -> do  # #storypoint-115
          sn = -> do
            sty.vtuple_class.new( 0 ).make_snitch @err
          end
          if ! x
            1  # we don't report this change currently but we could..
          elsif 0 > x
            sn[] << "(negative verbosity is meaningless - #{
              }bumping #{ x } up to 0.)"
            0
          elsif len < x
            sn[] << "(verbosity level #{ len } is the highest. #{
              }ignoring #{ x - len } of the verboses.)"
            len
          else
            x
          end
        end.call
        yes[ sty.vtuple_class.new x ]
        true
      end
    end
    private :build_normalizer_proc

    def lvl_a
      @vmod.lvl_a
    end

    def vtuple_class
      if const_defined? :Vtuple_, false
        const_get :Vtuple_, false
      else
        const_set :Vtuple_, Vtuple_.new( @vmod.lvl_a, self )
      end
    end
  end

  class Vtuple_

    class << self ; alias_method :orig_new, :new ; end

    def self.new lvl_a, mstory
      ::Class.new( self ).class_exec do
        class << self ; alias_method :new, :orig_new end
        const_set :Mstory_, mstory
        define_singleton_method :members do lvl_a end
        lvl_a.each do |i|
          attr_reader :"do_#{ i }"
        end
        self
      end
    end

    def self.get_snitch_class
      if const_defined? :Sn_, false
        const_get :Sn_, false
      else
        const_set :Sn_, Sn_.new( members )
      end
    end

    def initialize x
      ivar_a = members.map { |i| :"@do_#{ i }" }
      ivar_h = ::Hash[ members.zip ivar_a ]
      x.times do |i|
        instance_variable_set ivar_a.fetch( i ), true
      end
      ( x ... ivar_a.length ).each do |i|
        instance_variable_set ivar_a.fetch( i ), false
      end
      @aref = -> i do  # named after ruby's internal name for :[]
        ::Symbol === i or raise "sanity - needed symbol - #{ i.class }"
        instance_variable_get ivar_h.fetch( i )
      end
      nil
    end

    def members
      self.class.members
    end

    Callback_::Session::Ivars_with_Procs_as_Methods.call self, :@aref, :[]

    def make_snitch io, *expression_agent  # #storypoint-195
      self.class.get_snitch_class.new self, io, *expression_agent
    end
  end

  class Sn_  # #storypoint-200, part of the :+[#fa-051] snitch family

    class << self ; alias_method :orig_new, :new end

    def self.new a
      ::Class.new( self ).class_exec do
        class << self ; alias_method :new, :orig_new end
        a = a.dup.freeze
        define_singleton_method :members do a end
        a.each do |i|
          define_method :"do_#{ i }" do @is[ i ] end
          define_method i do | &blk |
            @say[ i, blk ]
          end
        end
        self
      end
    end

    def initialize vtuple, io, expression_agent=nil
      @write = -> s { io.write s }
      @puts = -> s { io.puts s }
      @say = -> i, *a, &p do  # #storypoint-225
        p_ = ( p ? a << p : a ).fetch( a.length - 1 << 1 )
        @is[ i ] and @puts[ expression_agent.instance_exec( & p_ ) ]
        nil
      end
      @is = -> i { vtuple[ i ] }
      @event = -> i, e do  # for now this gets flattened right away, but
        if @is[ i ]        # the emitter does not know that, which is the
          @puts[ nil.instance_exec( & e.message_proc ) ]  # point.
        end
        nil  # any result could be confusing (the e? the e iff emitted?)
      end
      @y = -> do
        y = ::Enumerator::Yielder.new( & y.method( :puts ) )
        @y = -> { y }
        y
      end
      nil
    end

    def members
      self.class.members
    end

    Callback_::Session::Ivars_with_Procs_as_Methods.call self,
      :write, :puts, :say, :is, :@puts, :<<, :event, :y
        # (reminder: ":@foo, :bar" means "use proc in @foo for method 'bar')
  end
  end
end
