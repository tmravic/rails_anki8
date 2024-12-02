class Api::V1::MovieSerializer < ActiveModel::Serializer
  attributes :title, :year
end
