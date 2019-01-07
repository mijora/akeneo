# frozen_string_literal: true

require 'akeneo/measure_family_service'

describe Akeneo::MeasureFamilyService do
  let(:url)          { 'http://akeneo.api' }
  let(:access_token) { 'access_token' }
  let(:service)      { described_class.new(url: url, access_token: access_token) }

  describe '#find' do
    let(:code) { 'a_measure_family_code' }
    let(:request_url) { "http://akeneo.api/api/rest/v1/measure-families/#{code}" }
    let(:response_body) { { 'code' => code }.to_json }
    let(:response_status) { 200 }
    let(:response_headers) { { 'Content-Type' => 'application/json' } }

    before do
      stub_request(:get, request_url).to_return(
        status: response_status,
        headers: response_headers,
        body: response_body
      )
    end

    it 'makes the code request' do
      service.find(code)

      expect(WebMock).to have_requested(
        :get,
        'http://akeneo.api/api/rest/v1/measure-families/a_measure_family_code'
      )
    end

    it 'it returns the response body' do
      response = service.find(code)

      expect(response).to eq('code' => 'a_measure_family_code')
    end

    context 'with failure' do
      let(:response_status) { 401 }

      it 'returns nil' do
        response = service.find(code)

        expect(response).to be(nil)
      end
    end
  end
end
