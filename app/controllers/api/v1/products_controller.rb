class Api::V1::ProductsController < Api::V1::ApiBaseController
  def index
    data = { message: "Hello from the API!" }
    render json: data, status: :ok
  end

  def show
    product = Product.find(params[:id])
    render json: product, serializer: Api::V1::ProductSerializer, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Product not found" }, status: :not_found
  end
end
