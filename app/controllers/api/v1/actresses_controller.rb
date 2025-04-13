class Api::V1::ActressesController < Api::V1::ApiBaseController
  def index
    @actresses = Actress.joins(:movies)
                        .select("actresses.id, actresses.name, movies.id as movie_id, movies.title, movies.year")
    render json: @actresses, each_serializer: Api::V1::ActressSerializer, status: :ok
  end

  def show
    actress = Actress.find(params[:id])
    render json: actress, serializer: Api::V1::ActressSerializer, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Actress not found" }, status: :not_found
  end
end
