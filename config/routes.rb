# frozen_string_literal: true

require "hanami/middleware/body_parser"
require "adamantium/middleware/process_params"

module Adamantium
  class Routes < Hanami::Routes
    use Hanami::Middleware::BodyParser, [:form, :json]
    # use Adamantium::Middleware::ProcessParams

    scope "micropub" do
      get "/", to: "site.config"
      post "/", to: "posts.handle"
      post "/media", to: "media.create"
      get "/media", to: "media.show"
    end

    get "/", to: "site.home"
    get "/post/:slug", to: "posts.show"
    get "/posts", to: "posts.index"

    get "/bookmarks", to: "bookmarks.index"
    get "/bookmarks/metadata/:id", to: "bookmarks.metadata"
    get "/bookmark/:slug", to: "bookmarks.show"

    get "/photos", to: "photos.index"
    get "/places", to: "places.index"

    get "/tagged/:slug", to: "tags.show"

    get "/key", to: "key.show" if Hanami.app.settings.micropub_pub_key

    get "/feeds/rss", to: "feeds.rss"

    get "/:slug", to: "pages.show"

    redirect "deploying-a-hanami-app-to-fly-io", to: "/post/deploying-a-hanami-20-app-to-flyio"
    redirect "deploying-a-hanami-app-to-fly-io/", to: "/post/deploying-a-hanami-20-app-to-flyio"
  end
end
