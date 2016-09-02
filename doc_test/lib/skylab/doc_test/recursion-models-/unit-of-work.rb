module Skylab::DocTest

  class RecursionModels_::UnitOfWork

    def initialize details, path
      @asset_path = path
      @_details = details
    end

    def express_into_under y, _expag
      tp = test_path
      ap = asset_path
      if tp && ap  # don't break our would-be CSV columns with blanks
        _create_or_update = CREATE_OR_UPDATE___.fetch test_path_is_real
        y << "#{ _create_or_update } #{ tp } #{ ap }"
      else
        y << "error:missing-path"
      end
      y
    end

    CREATE_OR_UPDATE___ = {
      true => 'would-update',
      false => 'would-create',
    }

    def test_path_is_real
      @_details.is_real
    end

    def test_path
      @_details.to_path
    end

    attr_reader(
      :asset_path,
    )
  end
end
