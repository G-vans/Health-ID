require 'graphql/client'
require 'graphql/client/http'

module TnIDAPI
  HTTP = GraphQL::Client::HTTP.new("https://api.staging.v2.tnid.com/company") do
    def headers(context)
      {
        "Authorization" => "Bearer #{context[:token]}"
      }
    end
  end

  Schema = GraphQL::Client.load_schema(HTTP)
  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
end
