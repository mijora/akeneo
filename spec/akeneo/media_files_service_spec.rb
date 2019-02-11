# frozen_string_literal: true

require 'akeneo/media_files_service'

describe Akeneo::MediaFilesService do
  let(:url)          { 'http://akeneo.api' }
  let(:access_token) { 'access_token' }
  let(:service)      { described_class.new(url: url, access_token: access_token) }

  describe '#find' do
    let(:file_code) { 'a_file_code' }
    let(:request_url) { "http://akeneo.api/api/rest/v1/media-files/#{file_code}" }
    let(:response_body) { { 'code' => file_code }.to_json }
    let(:response_status) { 200 }
    let(:response_headers) { { 'Content-Type' => 'application/json' } }

    before do
      stub_request(:get, request_url).to_return(
        status: response_status,
        headers: response_headers,
        body: response_body
      )
    end

    it 'makes the media files request' do
      service.find(file_code)

      expect(WebMock).to have_requested(
        :get,
        'http://akeneo.api/api/rest/v1/media-files/a_file_code'
      )
    end

    it 'it returns the response body' do
      response = service.find(file_code)

      expect(response).to eq('code' => 'a_file_code')
    end

    context 'with failure' do
      let(:response_status) { 401 }

      it 'returns nil' do
        response = service.find(file_code)

        expect(response).to be(nil)
      end
    end
  end

  describe '#download' do
    let(:file_code) { 'a_file_code' }
    let(:request_url) { "http://akeneo.api/api/rest/v1/media-files/#{file_code}/download" }
    let(:response_body) { 'pdf' }
    let(:response_status) { 200 }
    let(:response_headers) { { 'Content-Type' => 'application/pdf' } }

    before do
      stub_request(:get, request_url).to_return(
        status: response_status,
        headers: response_headers,
        body: response_body
      )
    end

    it 'makes the media files request' do
      service.download(file_code)

      expect(WebMock).to have_requested(
        :get,
        'http://akeneo.api/api/rest/v1/media-files/a_file_code/download'
      )
    end

    it 'it returns the response body' do
      response = service.download(file_code)

      expect(response).to eq('pdf')
    end

    context 'with failure' do
      let(:response_status) { 401 }

      it 'returns nil' do
        response = service.download(file_code)

        expect(response).to be(nil)
      end
    end
  end
end
