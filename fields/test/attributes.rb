module Skylab::Fields::TestSupport

  module Attributes

    class << self

      def [] tcc

        tcc.send :define_singleton_method, :given_the_attributes_ do | & p |
          shared_subject :the_attributes_ do
            instance_exec( & p )
          end
        end

        tcc.include self
      end

      def lib
        Home_::Attributes
      end
    end  # >>

    Build_emp_ent_meth__ = -> do
      entity_class_.new
    end

    Attribute_method__ = -> k do
      entity_class_.const_get( :ATTRIBUTES, false ).attribute k
    end

    define_method :build_empty_entity_, Build_emp_ent_meth__

    define_method :attribute_, Attribute_method__

    def attributes_ h
        subject_library_[ h ]
    end

    def against_ * x_a

      _ = the_attributes_
      _x = _.init self, x_a  # EGAGS
      _x.object_id == object_id or fail
    end

    def fails_
      false == state_.result or fail
    end

      def subject_library_
        Attributes.lib
      end

    # ==

    include( Entity_Killer_Methods = ::Module.new )

    module Meta_Attributes

      include Entity_Killer_Methods

      class << self

        def [] tcc
          tcc.include self
        end

        def lib
          Home_::Attributes
        end
      end  # >>

      def build_by_init_ * x_a
        build_by_init_via_sexp_ x_a
      end

      def build_by_init_via_sexp_ x_a

        cls = entity_class_
        o = cls.new  # `build_empty_entity_`
        _kp = cls::ATTRIBUTES.init o, x_a
        _kp && o
      end

      def where_ * x_a

        cls = entity_class_

        _ent = cls.new

        _ = event_log.handle_event_selectively

        _x = cls::ATTRIBUTES.init _ent, x_a, & _

        flush_event_log_and_result_to_state _x
      end

      define_method :build_empty_entity_, Build_emp_ent_meth__

      define_method :attribute_, Attribute_method__
    end

    # ==

    module Entity_Killer_Methods

      def self.[] tcc
        tcc.include self
      end

      # -- EEK for now we don't want to mess with the dependency of "expect event fail early"

      def expect_channel_looks_like_missing_required_ a
        expect_channel_ a, :error, :missing_required_attributes
      end

      def expect_channel_ a, * chan
        a[0] == chan || fail
      end

      def call_thru_normalize_ * x_a

        chan = nil ; ev_p = nil ; once = -> { once = nil ; }

        _scn = __build_API_style_argument_scanner_ATTR x_a do |*a, &p|
          once[]
          chan = a ; ev_p = p
        end

        _cls = entity_class_
        entity = _cls.new(){ [ _scn ] }

        yes_no = Home_::Attributes::Toolkit::Normalize[ entity ]

        case yes_no
        when false ; [ chan, ev_p ]

        when true
          chan && fail
          entity

        else ; never
        end
      end

      def __build_API_style_argument_scanner_ATTR a, & p

        _MTk_ = Zerk_lib_[]::MicroserviceToolkit
        _MTk_::API_ArgumentScanner.new a, & p
      end

      def given_definition_ * x_a
        @CLIENT = Parse_lib_[].test_support::Iambic_Grammar::Client.new x_a, self
        NIL
      end

      def flush_to_item_
        st = flush_to_item_stream_expecting_all_items_are_parameters_
        x = st.gets
        st.gets && fail
        x
      end

      def flush_to_item_stream_expecting_all_items_are_parameters_

        remove_instance_variable( :@CLIENT ).
          flush_to_item_stream_expecting_all_items_are :_parameter_FI_
      end

      def flush_to_stream_
        remove_instance_variable( :@CLIENT ).flush_to_stream
      end

      def subject_grammar
        Home_::Attributes::Toolkit.properties_grammar_
      end
    end

    # ==

    module Actor

      class << self

        def [] tcc
        tcc.send :define_singleton_method, :given_subject_class_ do |&p|
          define_method :subject_class_, Lazy_.call( & p )
        end
        tcc.include self
        end

        def lib
          Home_::Attributes::Actor
        end
      end  # >>

      def new_with_ * x_a
        sess = @class_.new
        _st = scanner_via_array_ x_a
        kp = sess.send :process_argument_scanner_fully, _st
        kp or ::Kernel.fail
        @session_ = sess ; nil
      end

      def process_argument_scanner_fully_via_ * x_a
        _st = scanner_via_array_ x_a
        @session_.send :process_argument_scanner_fully, _st
      end

      def process_argument_scanner_passively_ st
        @session_.send :process_argument_scanner_passively, st
      end

      def the_empty_argument_scanner_
        Common_::THE_EMPTY_SCANNER
      end

      def argument_scanner_via_ * x_a
        scanner_via_array_ x_a
      end

      def scanner_via_array_ x_a
        Common_::Scanner.via_array x_a
      end

      Here_ = self
    end

    # ==

    module EK_ModelMethods

      # (this is the bleeding edge of our trying-to-keep-it-minimial
      # necessary interface to use our new "E.K" normalization.
      # the reason for the funny method names (this sentence should be
      # moved to somewhere else) is exactly [#bs-028.1.1.2] )

      def initialize
        o = yield
        @_argument_scanner_ = o.first
      end

      def _write_ k, x
        instance_variable_set :"@#{ k }", x
      end

      def _read_ k
        ivar = :"@#{ k }"
        if instance_variable_defined? ivar
          instance_variable_get ivar
        end
      end

      def _listener_
        @_argument_scanner_.listener
      end

      def _argument_scanner_
        @_argument_scanner_  # hi.
      end
    end

    # ==
    # ==
  end
end
