# frozen_string_literal: true

require_relative './service_base.rb'

module Akeneo
  class MediaFilesService < ServiceBase
    def find(code)
      response = get_request("/media-files/#{code}")

      response.parsed_response if response.success?
    end

    def download(code)
      response = get_request("/media-files/#{code}/download")

      response.parsed_response if response.success?
    end
  end
end
