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

    def attributes_ h
      Home_::Attributes[ h ]
    end

    def against_ * x_a

      _ = the_attributes_
      _x = _.init self, x_a  # EGAGS
      _x.object_id == object_id or fail
    end

    Subject_module_ = -> do
      Home_::Attributes
    end

    module Meta_Attributes
      # (for now just a sandbox namespace)

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
        _st = polymorphic_stream_via_iambic_ x_a
        kp = sess.send :process_polymorphic_stream_fully, _st
        kp or ::Kernel.fail
        @session_ = sess ; nil
      end

      def process_polymorphic_stream_fully_via_ * x_a
        _st = polymorphic_stream_via_iambic_ x_a
        @session_.send :process_polymorphic_stream_fully, _st
      end

      def process_polymorphic_stream_passively_ st
        @session_.send :process_polymorphic_stream_passively, st
      end

      def the_empty_polymorphic_stream_
        Callback_::Polymorphic_Stream.the_empty_polymorphic_stream
      end

      def polymorphic_stream_via_ * x_a
        polymorphic_stream_via_iambic_ x_a
      end

      def polymorphic_stream_via_iambic_ x_a
        Callback_::Polymorphic_Stream.via_array x_a
      end

      Subject_proc_ = -> do
        Home_::Attributes::Actor
      end

      Subject_module_ = Subject_module_

      Here_ = self
    end
  end
end
