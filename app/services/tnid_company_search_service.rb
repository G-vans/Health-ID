module TnIDAPI
  COMPANY_SEARCH = TnIDAPI::Client.parse <<-'GRAPHQL'
    query ($name: String, $taxId: String, $limit: Int) {
      companies(name: $name, taxId: $taxId, limit: $limit) {
        id
        legalName
        brandName
        taxId
      }
    }
  GRAPHQL
end

class TnIDCompanySearchService
  def initialize(token)
    @token = token
  end

  def search(name: nil, tax_id: nil, limit: 5)
    TnIDAPI::Client.query(TnIDAPI::COMPANY_SEARCH, variables: { name: name, taxId: tax_id, limit: limit }, context: { token: @token })
  end
end
