#  @author = Patrick
class ProgressController < ApplicationController
  def show
    @bar = ProgressBar.find(params.fetch(:id))
    respond_to do |format|
      format.json{
         render json: @bar.to_json(only: [:current, :max, :percentage, :percent])
      }
    end
  end
end
