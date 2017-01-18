module Skylab::Fields::TestSupport

  module Attributes

    def self.[] tcc

      tcc.send :define_singleton_method, :given_the_attributes_ do | & p |

        shared_subject :the_attributes_ do

          instance_exec( & p )
        end
      end

      tcc.include self
    end

    Build_emp_ent_meth__ = -> do
      entity_class_.new
    end

    Attribute_method__ = -> k do
      entity_class_.const_get( :ATTRIBUTES, false ).attribute k
    end

    define_method :build_empty_entity_, Build_emp_ent_meth__

    define_method :attribute_, Attribute_method__

    def attributes_ h
      Home_::Attributes[ h ]
    end

    def against_ * x_a

      _ = the_attributes_
      _x = _.init self, x_a  # EGAGS
      _x.object_id == object_id or fail
    end

    def fails_
      false == state_.result or fail
    end

    Subject_module_ = -> do
      Home_::Attributes
    end

    module Meta_Attributes  # (NOTE sandbox namespace)

      def self.[] tcc
        tcc.include self
      end

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

      Subject_module_ = Subject_module_
    end

    module Actor  # (NOTE sandbox namespace)

      def self.[] tcc
        tcc.send :define_singleton_method, :given_subject_class_ do |&p|
          define_method :subject_class_, Lazy_.call( & p )
        end
        tcc.include self
      end

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

      Subject_proc_ = -> do
        Home_::Attributes::Actor
      end

      Subject_module_ = Subject_module_

      Here_ = self
    end
  end
end
