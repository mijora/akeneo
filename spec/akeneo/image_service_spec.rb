# frozen_string_literal: true

require 'akeneo/image_service'

describe Akeneo::ImageService do
  let(:url)          { 'http://akeneo.api' }
  let(:access_token) { 'access_token' }
  let(:service)      { described_class.new(url: url, access_token: access_token) }

  describe '#find' do
    let(:image_code) { 'an_image_code' }
    let(:request_url) { "http://akeneo.api/api/rest/v1/assets/#{image_code}" }
    let(:response_body) { { 'code' => image_code }.to_json }
    let(:response_status) { 200 }
    let(:response_headers) { { 'Content-Type' => 'application/json' } }

    before do
      stub_request(:get, request_url).to_return(
        status: response_status,
        headers: response_headers,
        body: response_body
      )
    end

    it 'makes the asset request' do
      service.find(image_code)

      expect(WebMock).to have_requested(
        :get,
        'http://akeneo.api/api/rest/v1/assets/an_image_code'
      )
    end

    it 'it returns the response body' do
      response = service.find(image_code)

      expect(response).to eq('code' => 'an_image_code')
    end

    context 'with failure' do
      let(:response_status) { 401 }

      it 'returns nil' do
        response = service.find(image_code)

        expect(response).to be(nil)
      end
    end
  end

  describe '#download' do
    let(:image_code) { 'an_image_code' }
    let(:request_url) { "http://akeneo.api/api/rest/v1/assets/#{image_code}/reference-files/no-locale/download" }
    let(:response_body) { 'lol' }
    let(:response_status) { 200 }
    let(:response_headers) { { 'Content-Type' => 'application/json' } }

    before do
      stub_request(:get, request_url).to_return(
        status: response_status,
        headers: response_headers,
        body: response_body
      )
    end

    it 'makes the reference file request' do
      service.download(image_code)

      expect(WebMock).to have_requested(
        :get,
        'http://akeneo.api/api/rest/v1/assets/an_image_code/reference-files/no-locale/download'
      )
    end

    it 'returns the body base64 encoded' do
      response = service.download(image_code)

      expected = Base64.strict_encode64(response_body)
      expect(response).to eq(expected)
    end

    context 'with failure' do
      let(:response_status) { 401 }

      it 'returns nil' do
        response = service.download(image_code)

        expect(response).to be(nil)
      end
    end
  end
end
