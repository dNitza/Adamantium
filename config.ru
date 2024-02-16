# frozen_string_literal: true

require "hanami/boot"

use Rack::Static, urls: ["/assets", "/media", "/fonts"], root: "public", cascade: true

raise StandardError.new("No secret key") unless ENV["SESSION_SECRET"]

use Rack::Session::Cookie,
  domain: URI.parse(ENV["MICROPUB_SITE_URL"]).host,
  path: "/",
  expire_after: 3600 * 72,
  secret: ENV["SESSION_SECRET"]

require "rack/rewrite"
use Rack::Rewrite do
  # remove trailing slashes
  r302 %r{(/.*)/(\?.*)?$}, "$1$2"
  r302 %r{/fonts/(.*)?$}, "/assets/$1"
end

require "adamantium/middleware/header_fix"
use Adamantium::Middleware::HeaderFix do |headers, env|
  unless headers["Content-Type"]&.include? "xml"
    headers["Content-Type"] = "text/html; charset=utf-8"
  end
end

run Hanami.app
