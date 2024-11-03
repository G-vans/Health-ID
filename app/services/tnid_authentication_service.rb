require 'http'

class TnIDAuthenticationService
  TOKEN_URL = "https://api.staging.v2.tnid.com/auth/token"

  def initialize(client_id, client_secret)
    @client_id = client_id
    @client_secret = client_secret
  end

  def fetch_bearer_token
    response = HTTP.post(TOKEN_URL, form: {
      client_id: @client_id,
      client_secret: @client_secret
    })

    if response.status.success?
      JSON.parse(response.body.to_s)['access_token']
    else
      raise "Failed to retrieve token: #{response.status} #{response.body.to_s}"
    end
  end
end
