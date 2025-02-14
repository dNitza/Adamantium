require "time_math"

module Main
  module Views
    module Posts
      class Show < Main::View
        include Deps["repos.post_repo", "repos.movie_repo", "settings"]

        expose :post do |slug:|
          Decorators::Posts::Decorator.new(post_repo.fetch!(slug))
        end

        expose :past_posts do |post|
          start_date = TimeMath.week.floor(post.published_at)
          end_date = TimeMath.week.ceil(post.published_at)
          posts = post_repo.from_the_archives(start_date: start_date, end_date: end_date)
          posts.map { |p| Decorators::Posts::Decorator.new(p) }
        end

        expose :past_movies do |post|
          start_date = TimeMath.week.floor(post.published_at)
          end_date = TimeMath.week.ceil(post.published_at)
          movies = movie_repo.from_the_archives(start_date: start_date, end_date: end_date)
          movies.map { |p| Decorators::Movies::Decorator.new(p) }
        end

        expose :bookmarks_this_week do |post|
          post_repo.bookmarks_for_week(date: post.published_at).map { |p| Decorators::Posts::Decorator.new(p) }
        end

        expose :text_posts do |past_posts|
          past_posts.reject(&:photos?)
        end

        expose :photo_posts do |past_posts|
          past_posts.select(&:photos?)
        end

        expose :trip do |post|
          post.trips.first
        end

        expose :reply_in_context do |post|
          if post.in_reply_to&.match settings.micropub_site_url
            slug = post.in_reply_to.split("/").last
            Decorators::Posts::Decorator.new(post_repo.fetch(slug))
          end
        end

        expose :replies do |post|
          post.webmentions.select { |w| w[:type] == "reply" }
        end

        expose :likes do |post|
          post.webmentions.select { |w| w[:type] == "like" }
        end

        expose :linked_data do |post|
          {
            "@context": "https://schema.org",
            "@type": "BlogPosting",
            headline: post.name,
            url: post.permalink,
            author: {
              "@type": "Person",
              name: "Daniel Nitsikopoulos",
              email: "hello@dnitza.com",
              url: "https://dnitza.com"
            },
            mainEntityOfPage: post.permalink,
            image: post.key_image,
            datePublished: post.published_at,
            dateCreated: post.published_at,
            dateModified: post.published_at
          }.to_json
        end
      end
    end
  end
end
