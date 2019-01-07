# frozen_string_literal: true

require_relative './service_base.rb'

module Akeneo
  class ProductModelService < ServiceBase
    def find(id)
      response = get_request("product-models/#{id}")

      response.parsed_response if response.success?
    end

    def all(with_family: nil)
      Enumerator.new do |product_models|
        url = "#{@url}/api/rest/v1/product-models?#{pagination_param}&#{limit_param}"
        url += search_with_family_param(with_family) if with_family

        loop do
          response = HTTParty.get(url, headers: default_request_headers)
          extract_collection_items(response).each { |product_model| product_models << product_model }
          url = extract_fetch_url(response)
          break unless url
        end
      end
    end

    private

    def search_with_family_param(family)
      "&search={\"family\":[{\"operator\":\"IN\",\"value\":[\"#{family}\"]}]}"
    end
  end
end
