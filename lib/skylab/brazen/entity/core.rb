module Skylab::Brazen

  module Entity

    class << self

      def [] * a
        via_argument_list a
      end

      def via_argument_list a
        case a.length
        when 1 ; via_proc a.first
        when 2 ; via_client_and_proc( * a )
        when 0 ; self
        else   ; raise ::ArgumentError, "not implemented - #{ a.length } args"
        end
      end

      def via_proc p
        mod = ::Module.new
        mod.const_set :Module_Methods, ::Module.new
        mod.extend Proprietor_Methods__
        mod.extend Extension_Module_Methods__
        mod.send :include, Iambic_Methods__
        mod.const_defined? READ_BOX__ or
          mod.const_set READ_BOX__, Box__.new
        apply_p_to_extension_module p, mod
        mod
      end

      def via_client_and_proc client, p
        client.extend Proprietor_Methods__
        client.send :include, Iambic_Methods__
        client.const_defined? READ_BOX__ or
          client.const_set READ_BOX__, Box__.new
        p and apply_p_to_client p, client
        nil
      end

      def apply_p_to_client p, client
        Method_Added_Muxer__[ client ].for_each_method_added_in p,
          Property__::Flusher.new( client.singleton_class, client ).
            method( :flush_because_method ) ; nil
      end

      def apply_p_to_extension_module p, mod
        Method_Added_Muxer__[ mod ].for_each_method_added_in p,
          Property__::Flusher.new( mod::Module_Methods, mod ).
            method( :flush_because_method ) ; nil
      end
    end

    READ_BOX__ = :PROPERTIES_FOR_READ__
    WRITE_BOX__ = :PROPERTIES_FOR_WRITE__

    module Proprietor_Methods__

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

      attr_reader :iambic_queue
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

      def merge_box! otr
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

    protected
      attr_reader :a, :h
    end

    class Method_Added_Muxer__  # from [mh] re-written
      class << self
        def [] mod
          me = self
          mod.module_exec do
            @method_added_muxer ||= me.bld_for self
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
      def method_added_notify method_i
        @p && @p[ method_i ] ; nil
      end
    end

    class Property__

      class Flusher
        def initialize definee_mod, proprietor_mod
          @definee = definee_mod
          @proprietor = proprietor_mod
        end
        def flush_because_method m_i
          m_i_ = :"produce_#{ m_i }_property"
          @proprietor.property_method_names_for_write.add_or_assert m_i, m_i_
          property = flsh_property m_i
          @definee.send :define_method, m_i_ do property end ; nil
        end
      private
        def flsh_property prop_i
          Property__.new prop_i
        end
      end

      def initialize prop_i
        @name = Callback_::Name.from_variegated_symbol prop_i
        @iambic_writer_method_name = prop_i
      end

      attr_reader :iambic_writer_method_name, :name
    end


    # ~ iambics

    module Iambic_Methods__
    private

      def process_iambic_fully * a
        prcss_iambic_passively_with_args a
        @d < @x_a.length and raise ::ArgumentError, say_strange_iambic
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
        when 0 ;
        when 1 ; @d ||= 0 ; @x_a, = a ; @x_a_length = @x_a.length
        when 2 ; @d, @x_a = a ; @x_a_length = @x_a.length
        else   ; raise ::ArgumentError, "(#{ a.length } for 0..2)"
        end
        subject = self.class
        box = subject.property_method_names
        while @d < @x_a.length
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
    end


    # ~ extension API

    module Extension_Module_Methods__

      def [] *a
        case a.length
        when 2 ; via_client_and_proc( * a )
        when 1 ; via_client( * a )
        else   ; raise ::ArgumentError, "no: (#{ a.length })"
        end
      end

      def via_client_and_proc client, p
        via_client client
        apply_p_to_client p, client
        nil
      end

      def via_client client
        client.extend Proprietor_Methods__
        client.extend self::Module_Methods
        if ! client.const_defined? READ_BOX__  # before we do any includes
          client.const_set READ_BOX__, Box__.new
        end
        client.send :include, self  # note this brings in iambic methods too
        _box = client.property_method_names_for_write
        _box_ = property_method_names
        _box.merge_box! _box_
        nil
      end

      def apply_p_to_client p, client  # #copy-paste
        Method_Added_Muxer__[ client ].for_each_method_added_in p,
          Property__::Flusher.new( client.singleton_class, client ).
            method( :flush_because_method ) ; nil
      end
    end
  end
end
