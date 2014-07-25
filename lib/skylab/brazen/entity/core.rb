module Skylab::Brazen

  module Entity

    class << self

      def [] * a
        via_argument_list a
      end

      def via_argument_list a
        if a.length.zero?
          Entity
        else
          Shell__.new.execute_via_argument_list a
        end
      end
    end

    class Common_Shell__

      def initialize
      end

      def execute_via_argument_list x_a
        @x_a = x_a
        case x_a.length
        when 2 ; when_two_length_arg_list_execute
        when 1 ; when_one_length_arg_list_execute
        when 0 ; when_zero_length_arg_list_execute
        else   ; when_many_length_arg_list_execute
        end
      end

      attr_writer :client, :p

      def process_option_iambic x_a
        @d = 0 ; process_iambic_fully x_a ; clear_all_iambic_ivars
      end
    private

      def when_zero_length_arg_list_execute
        raise ::ArgumentError, say_wrong_number_of_arguments
      end

      def when_two_length_arg_list_execute
        @client, @p = @x_a ; @x_a = nil
        to_client_apply_setup
        @p and to_client_via_p_apply ; nil  # #here-2
      end

      def when_many_length_arg_list_execute
        raise ::ArgumentError, say_wrong_number_of_arguments
      end

      def say_wrong_number_of_arguments
        "wrong number of arguments (#{ @x_a.length })"
      end

      def to_client_via_p_apply
        Method_Added_Muxer__[ @client ].for_each_method_added_in @p,
          flusher.with_two( @client.singleton_class, @client ).
            method( :flush_because_method ) ; nil
      end ; public :to_client_via_p_apply

      def flusher
        @flusher ||= Property__::Flusher.new
      end
    end

    class Shell__ < Common_Shell__
    private

      def when_one_length_arg_list_execute  # build extension moudule via proc
        @p = @x_a.first
        mod = ::Module.new
        mod.const_set :Module_Methods, ::Module.new
        mod.extend Proprietor_Methods__
        mod.extend Extension_Module_Methods__
        mod.send :include, Iambic_Methods__
        mod.const_set READ_BOX__, Box__.new
        apply_p_to_extension_module mod
        mod.has_nonzero_length_iambic_queue and
          Entity::Meta_Properties__.flush_iambic_queue_in_proprietor_module mod
        mod
      end

      def when_many_length_arg_list_execute  # parse options
        @client = @x_a.first ; @p = @x_a.last  # for now
        @d = 1 ; @x_a_length = @x_a.length - 1
        process_iambic_fully  # see #here-1
        to_client_apply_setup
        to_client_via_p_apply ; nil
      end

      def to_client_apply_setup
        @client.extend Proprietor_Methods__
        @client.send :include, Iambic_Methods__
        @client.const_defined? READ_BOX__ or
          @client.const_set READ_BOX__, Box__.new
        nil
      end

      def apply_p_to_extension_module mod
        Method_Added_Muxer__[ mod ].for_each_method_added_in @p,
          flusher.with_two( mod::Module_Methods, mod ).
            method( :flush_because_method ) ; nil
      end
    end

    READ_BOX__ = :PROPERTIES_FOR_READ__
    WRITE_BOX__ = :PROPERTIES_FOR_WRITE__

    module Proprietor_Methods__

      def properties
        @properties ||= Entity::Properties__.new( self )
      end

      def property_method_names_for_write
        if const_defined? WRITE_BOX__, false
          const_get WRITE_BOX__, false
        elsif const_defined? READ_BOX__, false
          const_set WRITE_BOX__, const_get( READ_BOX__, false )
        else
          props = property_method_names.dup
          const_set WRITE_BOX__, props
          const_set READ_BOX__, props
          props
        end
      end

      def property_method_names
        const_get READ_BOX__
      end

      def o * x_a
        ( @iambic_queue ||= [] ).push x_a ; nil
      end

      def has_nonzero_length_iambic_queue
        iambic_queue and @iambic_queue.length.nonzero?
      end

      attr_reader :iambic_queue

      def property_class_for_write  # :+#loader-hook
        Entity::Meta_Properties__.class
        property_class_for_write
      end
    end

    class Box__

      def initialize
        @a = [] ; @h = {}
      end

      def initialize_copy _otr_
        @a = @a.dup ; @h = @h.dup ; nil
      end

      def length
        @a.length
      end

      def get_local_normal_names
        @a.dup
      end

      def [] i
        @h[ i ]
      end

      # ~ mutators

      def ensuring_same_values_merge_box! otr
        a = otr.a ; h = otr.h
        a.each do |i|
          had = true
          m_i = @h.fetch i do
            had = false
          end
          if had
            m_i == @h.fetch( i ) or raise "merge failure near #{ m_i }"
          else
            @a.push i ; @h[ i ] = h.fetch i
          end
        end ; nil
      end

      def add_or_assert i, x
        has = true
        x_ = @h.fetch i do
          has = false
        end
        if has
          x == x_ or raise "assertion failure - not equal: (#{ x }, #{ x_ })"
          nil
        else
          @a.push i ; @h[ i ] = x ; true
        end
      end

      def add i, x
        had = true
        @h.fetch i do had = nil ; @a.push i ; @h[ i ] = x end
        had and raise ::KeyError, "won't clobber existing '#{ i }'"
      end

    protected
      attr_reader :a, :h
    end

    class Method_Added_Muxer__  # from [mh] re-written
      class << self
        def [] mod
          me = self
          mod.module_exec do
            @method_added_mxr ||= me.bld_for self
          end
        end
        def bld_for client
          muxer = new client
          client.send :define_singleton_method, :method_added do |m_i|
            muxer.method_added_notify m_i
          end
          muxer
        end
      end
      def initialize client
        @client = client ; @p = nil
      end
      def for_each_method_added_in defs_p, do_p
        add_listener do_p
        @client.module_exec( & defs_p )
        remove_listener do_p
      end
      def add_listener p
        @p and fail "not implemented - actual muxing"
        @p = p ; nil
      end
      def remove_listener _
        @p = nil
      end
      def stop_listening
        @stopped_p = @p ; @p = nil
      end
      def resume_listening
        @p = @stopped_p ; @stopped_p = nil
      end
      def method_added_notify method_i
        @p && @p[ method_i ] ; nil
      end
    end

    class Property__

      def initialize *a
        case a.length
        when 2
          prop_i, meth_i = a
          set_name_i prop_i
          set_iambic_writer_method_name meth_i
        when 0
        else
          a.length.zero? or raise ::ArgumentError, "(#{ a.length } for 0|2)"
        end
        block_given? and yield self
        emit_iambic_event :at_end_of_process_iambic
        freeze
      end

      attr_reader :iambic_writer_method_name, :name

      def set_name_i prop_i
        @name = Callback_::Name.from_variegated_symbol prop_i
      end

      def set_iambic_writer_method_name meth_i
        @iambic_writer_method_name = meth_i
      end

      def as_ivar
        @name.as_ivar
      end

      def name_i
        @name.as_variegated_symbol
      end

      def might_have_entity_class_hooks  # :+#re-defined elsewhere
        false
      end

      class Flusher
        def initialize
          @has_writer_method_name_constraints = false
        end
        attr_writer :property
        def writer_method_name_suffix= i
          @has_writer_method_name_constraints = true
          @method_name_constraints_rx = /\A.+(?=#{ ::Regexp.escape i }\z)/
          @writer_method_name_suffix = i
        end
        def with_two definee_mod, proprietor_mod
          @definee = definee_mod
          @proprietor = proprietor_mod
          self
        end
        def flush_because_method m_i
          @meth_i = m_i
          if @has_writer_method_name_constraints
            @prop_i = apply_method_name_constraints @meth_i
          else
            @prop_i = @meth_i
          end
          add_property flsh_property
        end
        def add_property property
          i = property.name_i
          m_i = :"produce_#{ i }_property"
          @proprietor.property_method_names_for_write.add_or_assert i, m_i
          @definee.send :define_method, m_i do property end
          property.might_have_entity_class_hooks and
            prcs_any_ent_cls_hks property
          nil
        end
      private
        def flsh_property
          if @proprietor.has_nonzero_length_iambic_queue
            flsh_meta_properties_and_property @proprietor.iambic_queue
          else
            @proprietor::PROPERTY_CLASS__.new @prop_i, @meth_i
          end
        end
        def flsh_meta_properties_and_property a
          Entity::Meta_Properties__.given_names_build_property do |mp|
            mp.proprietor = @proprietor ;  mp.prop_i = @prop_i
            mp.meth_i = @meth_i ; mp.queue = a
          end
        end
        def apply_method_name_constraints m_i
          md = @method_name_constraints_rx.match m_i.to_s
          md or raise ::NameError, say_did_not_have_expected_suffix( m_i )
          md[ 0 ].intern
        end
        def say_did_not_have_expected_suffix m_i
          "did not have expected suffix '#{ @writer_method_name_suffix }'#{
           }: '#{ m_i }'"
        end
      end
    end


    # ~ iambics

    module Iambic_Methods__
    private

      def process_iambic_fully * a
        prcss_iambic_passively_with_args a
        @d < @x_a_length and raise ::ArgumentError, say_strange_iambic
        self
      end

      def say_strange_iambic
        "unrecognized property '#{ @x_a[ @d ] }'"
      end

      def process_iambic_passively * a
        prcss_iambic_passively_with_args a
      end

      def prcss_iambic_passively_with_args a
        case a.length
        when 0 ; @d ||= 0 ; @x_a_length ||= @x_a.length
        when 1 ; @d ||= 0 ; @x_a, = a ; @x_a_length = @x_a.length
        when 2 ; @d, @x_a = a ; @x_a_length = @x_a.length
        else   ; raise ::ArgumentError, "(#{ a.length } for 0..2)"
        end
        subject = self.class
        box = subject.property_method_names
        while @d < @x_a_length
          m_i = box[ @x_a[ @d ] ]
          m_i or break
          @d += 1
          send subject.send( m_i ).iambic_writer_method_name
        end
        self
      end

      def iambic_property
        x = @x_a.fetch @d
        @d += 1
        x
      end

      def emit_iambic_event _  # :#re-defined elsewhere
      end

      PROPERTY_CLASS__ = Property__  # delicate
    end

    class Property__  # re-open now for meta-properties support
      Entity[ self, nil ]  # :#here-2
      public :process_iambic_fully
    end

    # ~ session options

    class Shell__

      Entity[ self, -> do
        def iambic_writer_method_name_suffix  # :#here-1
          flusher.writer_method_name_suffix = iambic_property
        end
      end ]
    end

    # ~ extension API

    module Extension_Module_Methods__

      def [] *a
        Extension_Shell__.new.execute_via_extmod_and_arglist self, a
      end

      def via_argument_list a
        Extension_Shell__.new.execute_via_extmod_and_arglist self, a
      end
    end

    class Extension_Shell__ < Common_Shell__

      def execute_via_extmod_and_arglist extension_module, arg_list
        @extension_module = extension_module
        execute_via_argument_list arg_list
      end

      def when_one_length_arg_list_execute
        @client = @x_a.first
        to_client_apply_setup ; nil
      end

      def to_client_apply_setup
        @client.extend Proprietor_Methods__
        @client.extend @extension_module::Module_Methods
        if ! @client.const_defined? READ_BOX__  # before we do any includes
          @client.const_set READ_BOX__, Box__.new
        end
        @client.send :include, @extension_module  # iambic methods too
        _box = @client.property_method_names_for_write
        _box_ = @extension_module.property_method_names
        _box.ensuring_same_values_merge_box! _box_ ; nil
      end
    end

    Entity = self
  end
end
