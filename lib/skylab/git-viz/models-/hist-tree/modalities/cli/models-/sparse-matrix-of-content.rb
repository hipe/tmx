module Skylab::GitViz

  class Models_::HistTree

    module Modalities::CLI

      Models_ = ::Module.new

      class Models_::Sparse_Matrix_of_Content

        class << self

          def new_via_bundle_and_repository bu, re

            Build___.new( bu, re ).execute
          end
        end  # >>

        def initialize row_a
          @rows = row_a
        end

        def members
          [ :rows ]
        end

        attr_reader :rows

        class Row___

          def initialize a, ttp
            @to_a = a ; @to_tree_path = ttp
          end

          def members
            [ :to_a, :to_tree_path ]
          end

          attr_reader :to_a, :to_tree_path
        end

        class Modality_Filechange__

          def initialize is_first, bundle_filechange

            @bundle_filechange_ = bundle_filechange
            @is_first = is_first
          end

          def members
            [ :author_datetime, :bundle_filechange_, :change_count,
              :ci, :is_first ]
          end

          attr_reader :bundle_filechange_
          attr_accessor :is_first

          def author_datetime
            @bundle_filechange_.ci.author_datetime
          end

          def change_count
            @bundle_filechange_.fc.change_count
          end

          def ci
            @bundle_filechange_.ci
          end
        end

        class Build___

          def initialize b, r
            @bundle = b
            @repository = r
          end

          def execute
            ok = __resolve_upstream_matrix
            ok &&= __via_upstream_matrix
            ok && __flush
          end

          def __resolve_upstream_matrix

            @matrix_ = @bundle.build_matrix_via_repository @repository
            @matrix_ && ACHIEVED_
          end

          def __via_upstream_matrix

            order_box = @matrix_.order_box
            @order_box_length = order_box.length
            @order_box_h = order_box.h_
            ACHIEVED_
          end

          def __flush

            Subject___.new( @matrix_.bundle.trails.map do | trail |
              Row___.new( __row_array_via_trail( trail ), trail.path )
            end )
          end

          def __row_array_via_trail trail

            row = ::Array.new @order_box_length

            st = Callback_::Stream.via_nonsparse_array trail.filechanges

            bundle_filechange = st.gets

            if bundle_filechange

              row[ @order_box_h.fetch bundle_filechange.SHA.string ] =

                Modality_Filechange__.new true, bundle_filechange

              begin

                bundle_filechange = st.gets
                bundle_filechange or break

                row[  @order_box_h.fetch bundle_filechange.SHA.string ] =
                  Modality_Filechange__.new false, bundle_filechange

                redo
              end while nil
            end
            row
          end
        end

        Subject___ = self
      end
    end
  end
end
