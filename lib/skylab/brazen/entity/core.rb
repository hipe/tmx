module Skylab::Brazen

  module Entity

    class << self

      def [] client, p
        client.extend Module_Methods__
        client.send :include, Iambic_Methods__
        if ! client.const_defined? :PROPERTIES_FOR_READ__
          client.const_set :PROPERTIES_FOR_READ__, Box__.new
        end
        if p
          Method_Added_Muxer__[ client ].for_each_method_added_in p,
            Property__::Flusher.new( client ).method( :flush_because_method )
        end
      end
    end

    module Module_Methods__

      def properties_for_write
        if const_defined? :PROPERTIES_FOR_WRITE__, false
          self::PROPERTIES_FOR_WRITE__
        elsif const_defined? :PROPERTIES_FOR_READ__, false
          const_set :PROPERTIES_FOR_WRITE__, self::PROPERTIES_FOR_READ__
        else
          props = properties.dup
          const_set :PROPERTIES_FOR_WRITE__, props
          const_set :PROPERTIES_FOR_READ__, props
          props
        end
      end

      def properties
        self::PROPERTIES_FOR_READ__
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

      def add i, x
        did = false
        @h.fetch i do
          did = true
          @a.push i
          @h[ i ] = x
        end
        did or raise ::KeyError, "can't add, key already exists: '#{ i }'"
        nil
      end
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
        def initialize client
          @client = client
        end
        def flush_because_method m_i
          m_i_ = :"produce_#{ m_i }_property"
          @client.properties_for_write.add m_i, m_i_
          property = flsh_property m_i
          @client.send :define_singleton_method, m_i_ do property end ; nil
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
        box = subject.properties
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
  end
end
