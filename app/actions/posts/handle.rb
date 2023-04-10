module Adamantium
  module Actions
    module Posts
      class Handle < Action
        before :authenticate!

        include Deps[
          "settings",
          "logger",
          "post_utilities.slugify",
          "repos.post_repo",
          post_param_parser: "param_parser.micropub_post",
          create_resolver: "commands.posts.creation_resolver",
          delete_post: "commands.posts.delete",
          undelete_post: "commands.posts.undelete",
          update_post: "commands.posts.update",
          add_post_syndication_source: "commands.posts.add_syndication_source"
        ]

        def handle(req, res)
          req_entity = post_param_parser.call(params: req.params.to_h)
          action = req.params[:action]

          # delete, undelete, update
          if action
            perform_action(req: req, res: res, action: action)
          elsif req_entity # create
            create_entry(req: req, res: res, req_entity: req_entity)
          end
        end

        private

        def create_entry(req:, res:, req_entity:)
          halt 401 unless verify_scope(req: req, scope: :create)

          command, contract = create_resolver.call(entry_type: req_entity).values_at(:command, :validation)
          post_params = prepare_params(req_entity.to_h)
          validation = contract.call(post_params)

          logger.info(req.params.inspect)

          if validation.success?
            command.call(validation.to_h).bind do |post|
              res.status = 201
              res.headers["Location"] = "#{settings.micropub_site_url}/#{post.post_type}/#{post.slug}"
            end
          else
            res.body = {error: validation.errors.to_h}.to_json
            res.status = 422
          end
        end

        def perform_action(req:, res:, action:)
          operation, permission_check = resolve_operation(action)

          halt 401 unless permission_check.call(req)

          operation.call(params: req.params.to_h)
          res.status = 200
        end

        def prepare_params(post_params)
          post = post_params.to_h
          post[:slug] = post[:slug].empty? ? slugify.call(text: post[:name], checker: post_repo.method(:slug_exists?)) : post[:slug]
          post
        end

        def resolve_operation(action)
          case action
          when "delete"
            [delete_post, ->(req) { verify_scope(req: req, scope: :delete) }]
          when "undelete"
            [undelete_post, ->(req) { verify_scope(req: req, scope: :undelete) }]
          when "update"
            [update_post, ->(req) { verify_scope(req: req, scope: :update) }]
          end
        end
      end
    end
  end
end
