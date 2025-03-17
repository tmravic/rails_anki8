FactoryBot.define do
  factory :movie do
    title { "Nosferatu the Vampyre" }

    transient do
      actress_name { "Isabelle Adjani" }
    end

    after(:create) do |movie, evaluator|
      create(:actress, name: evaluator.actress_name, movies: [movie])
    end
  end
end

# In this case, actress_name is a transient attribute.
# It doesn't get saved to the movie directly but is used
# to create an associated actress for the movie when the movie is created.

# Treat a transient block like a factory definition block.
# However, none of the attributes, associations, traits,
# or sequences you set will impact the final object.

# transient is for defining temporary attributes that
# don't get saved to the database, but can be used
# within the factory to modify how the object is created.