module Adamantium
  module Views
    module Posts
      class Index < Adamantium::View
        include Deps["repos.post_repo"]

        expose :posts do
          post_repo.post_listing.map do |post|
            Decorators::Posts::Decorator.new(post)
          end
        end

        expose :post_years do
          post_repo.post_years.map { |py| py[:year].to_i }
        end
      end
    end
  end
end
