module Skylab::SubTree

  class API::Actions::Cov

    class Upstream_

      Lib_::Contoured_fields[ self,
        :required, :field, :be_verbose,
        :required, :field, :info_p ]

      class Enumerator_ < ::Enumerator
        def initialize enumeration_class, *build_args, &blk
          @enumeration_class = enumeration_class
          @build_args = build_args ; @block = blk
          super( & method( :each_notify ) )
        end
      private
        def each_notify y
          @enumeration_class.new( y, @block, * @build_args ).execute
        end
      end
      class Enumeration_
        def initialize y, block
          @y = y ; @block = block
        end
        def execute
          instance_exec( & @block )
        end
      private
        def done x
          @y << x
          nil
        end
      end

      module From_
      end

      class From_::Filesystem_ < self

        Lib_::Contoured_fields[ self,
          :required, :field, :arg_pn ]

        def test_dir_pathnames
          Enumerator_.new Enumeration_, @arg_pn, @be_verbose, @info_p do
            -> do
              (( pn = @arg_pn )).exist? or break No_Such_Directory_[ pn ]
              pn.directory? or break No_Single_File_Support_[ pn ]
              TEST_DIR_NAME_A_.include? pn.basename.to_s and break done( pn )
                # if pn looks like foo/bar/test we are done
              (( pn_ = mutate_if_test_subnode )) and break done( pn_ )
                # if pn looks like foo/bar/test then we are done
              find_with_find
            end.call
          end
        end

        class Enumeration_ < Enumeration_
          def initialize y, block, arg_pn, be_verbose, info_p
            super y, block
            @arg_pn = arg_pn ; @be_verbose = be_verbose ; @info_p = info_p
          end
        private
          def find_with_find
            error_message = nil
            ok = Cov::Finder_[ :yielder, @y, :find_in_pn, @arg_pn,
              :info_p, @info_p, :be_verbose, @be_verbose,
              :error_p, -> errmsg { error_message = errmsg } ]
            Error_String_[ error_messgae] if ! ok
          end

          def mutate_if_test_subnode
            begin
              SOFT_RX_ =~ @arg_pn.to_s or break    # is test dir in the path?
              curr = @arg_pn ; seen_a = [ ] ; found = false
              until Stop_at_pathname_[ curr ]
                bn = curr.basename
                HARD_RX_ =~ bn.to_s and break( found = true )  # is the test dir?
                seen_a << bn.to_s
                curr = curr.dirname
              end
              found or break
              @sub_path_a and fail "sanity"  # #todo - when?
              @sub_path_a = seen_a.reverse # empty iff test dir was first dir
              r = curr
            end while nil
            r
          end
        end

        No_Such_Directory_ = Message_.new do |pn|
          "no such directory: #{ ick escape_path pn }"
        end

        No_Single_File_Support_ = Message_.new do |pn|
          "single file trees not yet implemented #{
            }(for #{ ick escape_path pn })"
        end

      end
    end
  end
end
