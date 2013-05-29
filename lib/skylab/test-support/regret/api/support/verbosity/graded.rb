class Skylab::TestSupport::Regret::API::Support::Verbosity::Graded < ::Module

  # the verbosity object created by this node is itself a module - it is
  # intended to be an immutable constant that is shared accross your
  # application. (it is a module because it is generally associated with
  # another constant: something like a static Conf module for your application,
  # and it generates one or more modules, and as such it is useful to store
  # these modules under it. :[#fa-032])

  Graded = self  # readability
  MetaHell = ::Skylab::MetaHell

  class Graded
    def self.produce_conf_module grade_i_a
      new grade_i_a
    end

    class << self
      private :new
    end

    def initialize grade_i_a
      @lvl_a = grade_i_a.dup.freeze
    end

    attr_reader :lvl_a

    def [] mod_x
      wat = Aggregate_.const_get mod_x.metastory.aggregate_exponent, false
      wat[ self, mod_x ]
    end
  end

  module Aggregate_
  end

  module Aggregate_::CLI_Modality_Client_
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

  module Aggregate_::CLI_Modality_Client_::IM_
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

  module Aggregate_::API_Action_
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

  class Aggregate_::API_Action_::Mutable_Vstory_ < ::Module

    def initialize vmod, api_application_class
      @param_i = nil
      @default_level_integer = 1
      @vmod, @api_application_class = vmod, api_application_class
    end

    # `param` - you chose the name, we do the rest.

    def param i
      @param_i and fail "param ame is write once."
      @param_i = i
      [ i, :normalizer,  build_normalizer_function ]
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

    def build_normalizer_function
      sty = self
      -> y, x, yes do
        lvl_a = sty.lvl_a ; len = lvl_a.length
        x = -> do  # actually normalize x ..
          # 3 things: 1) to report the validation articulations below, we build
          # a one-off valid vtuple and use *its* snitch! (for grease) 2) we
          # don't report re. setting a default below but we could and 3)
          # be ready for one day revealing the below articulation.
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
    private :build_normalizer_function

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
        instance_variable_get ivar_h.fetch( i )
      end
      nil
    end

    def members
      self.class.members
    end

    MetaHell::Function self, :@aref, :[]

    # `make_snitch` - (formerly `sc` for "sub-client")
    # quick and dirty proof of concept, will almost certainly change. the idea
    # is a simpler alternative to pub-sub. what if you could throw one
    # listener around throughout your graph? the listener is like a golden
    # snitch. no it isn't.

    def make_snitch io
      self.class.get_snitch_class.new self, io
    end
  end

  class Sn_ # see Vtuple_IM_#sc

    # the snitch itself is technically "immutable" but it just closes around
    # the vtuple and relies on the vtuple as the datastore. if the vtuple
    # changes its state (in terms of its category values, not its categories!)
    # the snitch will act accordingly.

    class << self ; alias_method :orig_new, :new end

    def self.new a
      ::Class.new( self ).class_exec do
        class << self ; alias_method :new, :orig_new end
        a = a.dup.freeze
        define_singleton_method :members do a end
        a.each do |i|
          define_method :"do_#{ i }" do @is[ i ] end
        end
        self
      end
    end

    def initialize vtuple, io
      @write = -> s { io.write s }
      @puts = -> s { io.puts s }
      @say = -> i, f do
        if @is[ i ]
          @puts[ nil.instance_exec( & f ) ]  # future-proofing grease
        end # ( one day we might give it a context but for now we don't want
        nil #   to give it a misleading context.)
      end
      @is = -> i { vtuple[ i ] }
      nil
    end

    def members
      self.class.members
    end

    MetaHell::Function self, :write, :puts, :say, :is, :@puts, :<<, :@is, :[]
      # ( because we often forget, the above is "use @puts for :<<" etc )
  end
end
