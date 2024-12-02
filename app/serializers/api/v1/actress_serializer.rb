class Api::V1::ActressSerializer < ActiveModel::Serializer
  attributes :name

  has_many :movies, serializer: Api::V1::MovieSerializer
end
