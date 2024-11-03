module TnIDAPI
  SEND_B2B_CONNECTION_REQUEST = TnIDAPI::Client.parse <<-'GRAPHQL'
    mutation($invitedCompanyId: ID!, $connectionType: B2bConnectionType!) {
      createB2bConnectionRequest(invitedCompanyId: $invitedCompanyId, connectionType: $connectionType) {
        id
        status
        company { id }
        invitedCompany { id }
      }
    }
  GRAPHQL
end

class TnIDConnectionRequestService
  def initialize(token)
    @token = token
  end

  def send_request(invited_company_id, connection_type)
    TnIDAPI::Client.query(TnIDAPI::SEND_B2B_CONNECTION_REQUEST, variables: { invitedCompanyId: invited_company_id, connectionType: connection_type }, context: { token: @token })
  end
end
