module Skylab::Basic

  module Tree

    class Sessions_::Merge  # towards [#040], part of :+[#mh-014] diaspora

      class << self

        def merge_atomic x, x_
          Merge_::Actors__::Merge[ x, x_, :merge_atomic ]
        end

        def merge_one_dimensional x, x_
          Merge_::Actors__::Merge[ x, x_, :merge_one_dimensional ]
        end

        def merge_union x, x_
          Merge_::Actors__::Merge[ x, x_, :merge_union ]
        end
      end  # >>

      def initialize destructee, mutatee

        @destructee = destructee
        @mutatee = mutatee
      end

      def execute

        P__[ @mutatee.to_constituents, @destructee.to_constituents ]

        P__[ @mutatee, @destructee ]
      end

      P__ = -> mutatee, destructee do

        st = destructee.to_polymorphic_key_stream

        while st.unparsed_exists
          key = st.gets_one
          item_ = destructee.remove key
          if item_.nil?
            next
          end

          none = false
          item = mutatee.fetch key do
            none = true
          end

          if none
            mutatee.add key, item_
            next
          end

          item.merge_destructively item_
        end
        NIL_
      end

      class Constituents

        def initialize o, * ivars
          @o = o
          @ivars = ivars
        end

        def to_polymorphic_key_stream

          Callback_::Stream.via_nonsparse_array( @ivars ).reduce_by do | k |

            @o.instance_variable_defined? k

          end.flush_to_polymorphic_stream
        end

        def fetch k

          if block_given?
            if @o.instance_variable_defined? k
              @o.instance_variable_get k
            else
              yield
            end
          else
            @o.instance_variable_get k
          end
        end

        def add k, x

          if @o.instance_variable_defined? k
            raise
          else
            @o.instance_variable_set k, x
          end
        end

        def remove k

          if block_given?
            if @o.instance_variable_defined? k
              @o.remove_instance_variable k
            else
              yield
            end
          else
            @o.remove_instance_variable k
          end
        end
      end

      Merge_ = self
    end
  end
end
# :+#tombstone: comments deleted here show how ridiculously, sub-optimally byzantine "box-multi" was
