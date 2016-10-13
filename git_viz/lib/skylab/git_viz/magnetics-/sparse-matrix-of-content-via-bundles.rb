module Skylab::GitViz

  class Models_::HistTree

    module Magnetics_::SparseMatrix_of_Content_via_Bundles

      class << self

        def call bu, re
          Build___.new( bu, re ).execute
        end

        alias_method :[], :call
      end  # >>

      # ==

      class ModalityFilechange__
        # -
          def initialize is_first, bundle_filechange
            @bundle_filechange_ = bundle_filechange
            @is_first = is_first
          end

          def author_datetime
            @bundle_filechange_.ci.author_datetime
          end

          def change_count
            @bundle_filechange_.fc.change_count
          end

          def ci
            @bundle_filechange_.ci
          end

        # -

        attr_accessor(
          :is_first,
        )

        attr_reader(
          :bundle_filechange_,
        )
      end

      # ==

      class Build___
        # -
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

          _row_a = @matrix_.bundle.trails.map do |trail|
            _row_a_ = __row_array_via_trail trail
            Row___[ _row_a_, trail.path ]
          end

          SparseMatrix___.new _row_a
        end

          def __row_array_via_trail trail

            row = ::Array.new @order_box_length

            st = Common_::Stream.via_nonsparse_array trail.filechanges

            bundle_filechange = st.gets

            if bundle_filechange

              row[ @order_box_h.fetch bundle_filechange.SHA.string ] =

                ModalityFilechange__.new true, bundle_filechange

              begin

                bundle_filechange = st.gets
                bundle_filechange or break

                row[  @order_box_h.fetch bundle_filechange.SHA.string ] =
                  ModalityFilechange__.new false, bundle_filechange

                redo
              end while nil
            end
            row
          end
        # -
      end

      # ==

      SparseMatrix___ = ::Struct.new :rows

      Row___ = ::Struct.new :to_a, :to_tree_path

      # ==
    end
  end
end
