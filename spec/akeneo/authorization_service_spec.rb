# frozen_string_literal: true

require 'akeneo/authorization_service'

describe Akeneo::AuthorizationService do
  let(:headers)       { { 'Content-Type' => 'application/json' } }
  let(:url)           { 'http://akeneo.api' }
  let(:client_id)     { 'client_id' }
  let(:password)      { 'password' }
  let(:secret)        { 'secret' }
  let(:username)      { 'username' }
  let(:access_token)  { 'NzFiYTM4ZTEwMjcwZTcyZWIzZTA0NmY3NjE3MTIyMjM1Y2NlMmNlNWEyMTAzY2UzYmY0YWIxYmUzNTkyMDcyNQ' }
  let(:refresh_token) { 'MDk2ZmIwODBkYmE3YjNjZWQ4ZTk2NTk2N2JmNjkyZDQ4NzA3YzhiZDQzMjJjODI5MmQ4ZmYxZjlkZmU1ZDNkMQ' }
  let(:service) { described_class.new(url: url) }

  describe '#authorize!' do
    let(:status) { 200 }
    let(:body) do
      {
        'access_token': access_token,
        'expires_in': 3600,
        'token_type': 'bearer',
        'scope': nil,
        'refresh_token': refresh_token
      }.to_json
    end

    before do
      stub_request(:post, 'http://akeneo.api/api/oauth/v1/token').to_return(
        status: status,
        body: body,
        headers: headers
      )
    end

    it 'authorizes the user' do
      service.authorize!(client_id: client_id, secret: secret, username: username, password: password)

      expected = {
        body: {
          username: username,
          password: password,
          grant_type: 'password'
        }.to_json,
        headers: {
          'Authorization': 'Basic Y2xpZW50X2lkOnNlY3JldA==',
          'Content-Type': 'application/json'
        }
      }
      expect(WebMock).to have_requested(:post, 'http://akeneo.api/api/oauth/v1/token').with(expected)
    end

    it 'caches the access token' do
      expect { service.authorize!(client_id: client_id, secret: secret, username: username, password: password) }
        .to change { service.access_token }
        .from(nil)
        .to(access_token)
    end

    it 'caches the refresh token' do
      expect { service.authorize!(client_id: client_id, secret: secret, username: username, password: password) }
        .to change { service.refresh_token }
        .from(nil)
        .to(refresh_token)
    end

    context 'with failing authentication' do
      let(:status) { 422 }
      let(:body) { { 'code': 422, 'message': 'No user found for the given username and password' }.to_json }

      it 'raises an error' do
        expect do
          service.authorize!(client_id: client_id, secret: secret, username: username, password: password)
        end.to raise_error('No user found for the given username and password')
      end
    end
  end

  describe '#fresh_access_token' do
    let(:last_refresh) { Time.now }

    before do
      service.access_token = access_token
      service.refresh_token = refresh_token
      service.last_refresh = last_refresh
    end

    it 'returns the valid access token' do
      expect(service.fresh_access_token).to eql(access_token)
    end

    context 'when access token is older than threshhold' do
      let(:last_refresh) { Time.now - 2001 }

      let(:refreshed_access_token)  { 'a_refreshed_access_token' }
      let(:refreshed_refresh_token) { 'a_refreshed_refresh_token' }
      let(:status) { 200 }
      let(:body) do
        {
          'access_token': refreshed_access_token,
          'expires_in': 3600,
          'token_type': 'bearer',
          'scope': nil,
          'refresh_token': refreshed_refresh_token
        }.to_json
      end
      before do
        stub_request(:post, 'http://akeneo.api/api/oauth/v1/token').to_return(
          status: status,
          body: body,
          headers: headers
        )
      end

      it 'makes the refresh request' do
        service.fresh_access_token

        expected = {
          body: {
            refresh_token: refresh_token,
            grant_type: 'refresh_token'
          }.to_json,
          headers: {
            'Authorization': 'Basic Og==',
            'Content-Type': 'application/json'
          }
        }
        expect(WebMock).to have_requested(:post, 'http://akeneo.api/api/oauth/v1/token').with(expected)
      end

      it 'refreshs the access token' do
        expect { service.fresh_access_token }
          .to change { service.access_token }
          .from(access_token)
          .to(refreshed_access_token)
      end

      it 'refreshs the refresh token' do
        expect { service.fresh_access_token }
          .to change { service.refresh_token }
          .from(refresh_token)
          .to(refreshed_refresh_token)
      end

      it 'returns the access token' do
        expect(service.fresh_access_token).to eql(refreshed_access_token)
      end
    end
  end
end
