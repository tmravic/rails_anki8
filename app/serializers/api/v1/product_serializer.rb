class Api::V1::ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :sku, :price, :category

  def category
    object.category.name
  end
end
