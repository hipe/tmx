module Skylab::GitViz

  module Test_Lib_

    module Mock_Sys

      Models_ = ::Module.new

      class Models_::Command

        class << self

          def unmarshalling_stream x, sym

            Build_unmarshalling_stream___[ x, sym, self ]
          end
        end  # >>

        def initialize
          @exitstatus = nil
          @stdout_string = nil
          @stderr_string = nil
          @argv = nil
        end

        attr_accessor :exitstatus, :stdout_string, :stderr_string, :argv

        def write_to io

          oa = Mock_Sys_::Output_Adapters_::OGDL_esque.new io, :command

          if @argv
            oa.write @argv, :argv, :string_array
          end

          if @stdout_string
            oa.write @stdout_string, :stdout_string, :string
          end

          if @stderr_string
            oa.write @stderr_string, :stderr_string, :string
          end

          if @exitstatus
            oa.write @exitstatus, :exitstatus, :number
          end

          oa.flush
          NIL_
        end

        # ~ begin

        def read_from_tree tree  # result must be self on success

          ok = true
          tree.children.each do | node |
            ok = send :"__unmarshal__#{ node.string }__from_node", node
            ok or break
          end
          ok and self
        end

        def __unmarshal__argv__from_node node

          @argv = node.children.map do | nd |
            nd.string
          end
          ACHIEVED_
        end

        def __unmarshal__exitstatus__from_node nd

          s = _insist_on_one_string nd
          s and begin
            if D_RX___ =~ s
              @exitstatus = s.to_i
              ACHIEVED_
            else
              fail "is not an exitstatus: #{ s.inspect }"
            end
          end
        end
        D_RX___ = /\A[0-9]+\z/

        def __unmarshal__stdout_string__from_node nd

          @stdout_string = _insist_on_one_string nd
        end

        def __unmarshal__stderr_string__from_node nd

          @stderr_string = _insist_on_one_string nd
        end

        def _insist_on_one_string nd

          a = nd.children
          a.fetch( a.length - 1 << 1 ).string
        end

        # ~ end
      end

      Build_unmarshalling_stream___ = -> x, sym, model_class do

        st = Mock_Sys_::Input_Adapters_.const_get( sym ).tree_stream_from_lines( x )

        Callback_.stream do

          tree = st.gets
          tree and begin

            model_class.new.read_from_tree tree
          end
        end
      end

      Mock_Sys_ = self
    end
  end
end
