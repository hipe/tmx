module Skylab::Basic

  module Set  # simple param normalization, inner & outer difference always
      # :+[#sl-116] distilled from [gi]. also used by [sg].

    def self.[] mod, * x_a
      Bundles__.apply_iambic_on_client x_a, mod
    end

    def self.to_proc
      Bundles__.to_proc
    end

    module Bundles__

      Basic_set_bork_event_listener_p = -> x_a do
        const_set :BASIC_SET_BORK_EVENT_LISTENER_P__, x_a.shift ; nil
      end

      Initialize_basic_set_with_hash = -> _ do
      private
        def initialize_basic_set_with_hash h
          Initialize_basic_set_with_hash__[ self, h ]
        end
      end

      Initialize_basic_set_with_iambic = -> _ do
      private
        def initialize_basic_set_with_iambic x_a
          Initialize_basic_set_with_iambic__[ self, x_a ]
        end
      end

      With_members = -> x_a do
        x = x_a[ 0 ]
        module_exec x, & With_members__
        x_a.shift ; nil
      end

      Basic::Lib_::Bundle_Multiset[ self ]
    end

    With_members__ = -> x do
      module_exec x, & (
        if x.respond_to? :each_with_index then With_members_as_a__
        elsif x.respond_to? :call then With_members_as_p__
        else raise ::ArgumentError,
          "member set? #{ Basic::FUN::Inspect[ x ] }" end ) ; nil
    end
    With_members_as_a__ = -> a do
      a.frozen? or raise ::ArgumentError, "when providing an array to #{
        }use as the member list, it must be frozen"
      p = -> do
        set = Basic::Lib_::Set[ a ].freeze
        p = -> { set } ; set
      end
      define_method :basic_set_member_set do p[] end
    end
    With_members_as_p__ = -> p do
      define_method :basic_set_member_set do
        self.class.basic_set_member_set_from_p do
          _a = instance_exec( & p )
          Basic::Lib_::Set[ _a ].freeze
        end
      end
      def self.basic_set_member_set_from_p & build_set_p
        @basic_set_member_set_from_p ||= build_set_p[]  # covered
      end
    end
    class Common_Runtime__
      Basic::Lib_::Funcy_globful[ self ]
      def initialize agent
        @agent = agent
        @agent_mod = agent.class
        @bork_p = resolve_some_bork_p
        @member_set = agent.basic_set_member_set ; nil
      end
    private
      def start_parse
        p = Execute__.new
        p.agent = @agent
        p.bork_p = @bork_p
        p.member_set = @member_set
        p.vessel_x = @agent
        p
      end

      def resolve_some_bork_p
        if @agent_mod.const_defined? :BASIC_SET_BORK_EVENT_LISTENER_P__
          -> ev do
            _p = @agent_mod::BASIC_SET_BORK_EVENT_LISTENER_P__
            @agent.instance_exec ev, & _p
          end
        else
          -> ev do
            raise ::ArgumentError, ev.string
          end
        end
      end

      ZERO_P__ = -> { 0 }

      def bork ev
        @bork_p[ ev ]
      end
    end

    class Bork__ < ::Struct  # :+[#hl-132] variant of the magical Event cl..
      def self.new &p
        super( * p.parameters.map( & :last ) ) do
          define_method :message_proc do p end
        end
      end
      def string
        nil.instance_exec( * to_a, & message_proc )
      end
    end

    class Initialize_basic_set_with_hash__ < Common_Runtime__
      def initialize agent, h
        @h = h ; super agent
      end
      def execute
        p = start_parse
        p.input_pairs = @h
        p.execute
      end
    end

    class Initialize_basic_set_with_iambic__ < Common_Runtime__
      def initialize agent, x_a
        @x_a = x_a ; super agent
      end
      def execute
        if @x_a.respond_to? :each_with_index
          correct_shape
        else
          incorrect_shape
        end
      end
    private
      def incorrect_shape
        bork Incorrect_Shape[ @x_a, @agent ]
      end
      Incorrect_Shape = Bork__.new do |x, agent|
        "expected array-ish for iambic argument, had #{ x.class } #{
          }for #{ agent.class }"
      end

      def correct_shape
        if ( @x_a.length % 2 ).zero?
          even
        else
          odd
        end
      end

      def odd
        bork Non_Iambic_Count[ @x_a, @agent ]
      end

      Non_Iambic_Count = Bork__.new do |a, agent|
        "the count of the iambic arguments must be even. had #{ a.length } #{
          }arguments for #{ agent.class }"
      end

      def even
        p = start_parse
        p.input_pairs = Each_Pair_Scanner__.new @x_a
        p.execute
      end
    end

    class Each_Pair_Scanner__ < ::Proc
      # ::Hash[ 0.step( @x_a.length - 1, 2 ).map { |d| @x_a[ d .. d + 1 ] } ]
      def self.new x_a
        p = -> do
          if x_a.length.nonzero?
            r = [ x_a.shift, x_a.shift ]
            p = -> do
              if x_a.length.nonzero?
                r[ 0 ] = x_a.shift ; r[ 1 ] = x_a.shift ; r
              end
            end ; r
          end
        end
        super() do p[] end
      end
      alias_method :gets, :call
      def each_pair &p
        while (( a = gets ))
          p[ * a ]
        end ; nil
      end
    end

    class Execute__

      # (no `initialize`)

      attr_writer( * %i( agent bork_p member_set input_pairs
        error_count_p vessel_has_p vessel_write_p vessel_x ) )

      def execute
        @x_is_considered_as_provided_p ||= method :x_is_considered_as_provided
        @vessel_has_p ||= get_default_vessel_has_p
        @vessel_has_priv_writer_p ||= get_default_vessel_has_priv_writer_p
        @vessel_write_p ||= get_default_vessel_write_p
        @error_count_p ||= get_default_error_count_p
        befor = @error_count_p[]
        traverse
        if @xtra_k_a then
          extra
        elsif some_are_missing
          missing
        else
          befor == @error_count_p[]
        end
      end
    private
      def x_is_considered_as_provided x
        ! x.nil?
      end
      def get_default_error_count_p
        some_vessel_x.instance_exec do
          -> do
            if instance_variable_defined? :@error_count
              @error_count
            else
              0
            end
          end
        end
      end
      def get_default_vessel_has_p
        is_provided_p = @x_is_considered_as_provided_p
        some_vessel_x.instance_exec do
          -> fld do
            ivar = fld.ivar
            instance_variable_defined?( ivar ) &&
              is_provided_p[ instance_variable_get ivar ]
          end
        end
      end
      def get_default_vessel_has_priv_writer_p
        p = some_vessel_x.class.method :private_method_defined?
        -> fld do
          p[ fld.writer_i ]
        end
      end
      def get_default_vessel_write_p
        some_vessel_x.instance_exec do
          -> fld, x do
            instance_variable_set fld.ivar, x ; nil
          end
        end
      end
      def some_vessel_x
        @vessel_x or fail "sanity - no @vessel_x"
      end
      def traverse
        @xtra_k_a = nil ; @provided = Basic::Lib_::Set[]
        @fld = Memberhood_Unit_of_Work__.new
        @input_pairs.each_pair do |k, v|
          @fld.replace k, v
          visit
        end ; nil
      end
      def visit
        k = @fld.k ; x = @fld.x
        if @member_set.include? k
          if @x_is_considered_as_provided_p[ x ]
            @provided.add? k
            if @vessel_has_priv_writer_p[ @fld ]
              @vessel_x.send @fld.writer_i, x
            else
              @vessel_x.instance_variable_set @fld.ivar, x
            end
          end
        else
          (( @xtra_k_a ||= [] )) << k
        end ; nil
      end

      class Memberhood_Unit_of_Work__
        # "memberhood" the made-up term is defined at [#hl-118]
        def replace k, x=nil
          @ivar = nil ; @k = k ; @writer_i = :"#{ k }=" ; @x = x ; nil
        end
        attr_reader :k, :writer_i, :x
        def ivar
          @ivar ||= :"@#{ @k }"
        end
      end

      def extra
        @bork_p[ Extra[ @xtra_k_a, @agent ] ]
      end
      Extra = Bork__.new do |xtra_k_a, agent|
        "unrecognized parameter(s): (#{ xtra_k_a * ', ' }) #{
          }for #{ agent.class }"
      end

      def some_are_missing
        @miss_k_a = @member_set.reduce [] do |m, k|
          @provided.include?( k ) and next m
          @fld.replace k
          @vessel_has_p[ @fld ] and next m
          m << k
        end
        @miss_k_a.length.nonzero?
      end

      def missing
        @bork_p[ Missing[ @miss_k_a, @agent ] ]
      end
      Missing = Bork__.new do |miss_k_a, agent|
        "missing required parameter(s): (#{ miss_k_a.join ', ' }) for #{
          }#{ agent.class }"
      end
    end
  end
end
