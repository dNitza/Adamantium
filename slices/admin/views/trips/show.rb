module Admin
  module Views
    module Trips
      class Show < Admin::View
        include Deps["repos.trip_repo", "repos.post_repo"]

        expose :trip do |id:|
          trip_repo.fetch(id)
        end

        expose :posts do |trip|
          post_repo.created_between(trip.start_date, trip.end_date).map do |post|
            Adamantium::Decorators::Posts::Decorator.new(post)
          end
        end
      end
    end
  end
end
