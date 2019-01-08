# frozen_string_literal: true

require 'redis'
require 'akeneo/cache'
require 'httparty'

describe Akeneo::Cache do
  class DummyService
    prepend Akeneo::Cache

    def call
      get_request('https://www.google.com', headers: {})
    end

    private

    def get_request(path, options = {})
      HTTParty.get(path, options)
    end
  end

  let(:redis) { instance_double(Redis) }

  before do
    described_class.disabled = false
  end

  after do
    described_class.disabled = true
  end

  describe '.redis' do
    it 'initializes a redis client' do
      allow(Redis).to receive(:new) { redis }

      DummyService.redis

      expect(Redis).to have_received(:new)
    end
  end

  describe '#get_request' do
    context 'when disabled' do
      before do
        described_class.disabled = true

        stub_request(:get, 'https://www.google.com/').to_return(status: 200, body: '', headers: {})
      end

      it 'makes the http request' do
        DummyService.new.call

        expect(WebMock).to have_requested(:get, 'https://www.google.com')
      end

      it 'does not call redis at all' do
        allow(DummyService).to receive(:redis)

        DummyService.new.call

        expect(DummyService).not_to have_received(:redis)
      end
    end

    context 'without redis connection' do
      before do
        expect(DummyService).to receive(:redis) { redis }
        expect(redis).to receive(:get).and_raise(Redis::CannotConnectError)
        allow(redis).to receive(:set)

        stub_request(:get, 'https://www.google.com/').to_return(status: 200, body: '', headers: {})
      end

      it 'makes the http request' do
        DummyService.new.call

        expect(WebMock).to have_requested(:get, 'https://www.google.com')
      end

      it 'does not execute the redis set command' do
        DummyService.new.call

        expect(redis).not_to have_received(:set)
      end
    end

    context 'with redis connection and cache hit' do
      let(:cache) { 'foo' }

      before do
        expect(DummyService).to receive(:redis) { redis }
        allow(redis).to receive(:get) { Marshal.dump(cache) }
        allow(redis).to receive(:set)
      end

      it 'returns the cached data' do
        result = DummyService.new.call

        expect(result).to eq(cache)
      end

      it 'does not execute the redis set command' do
        DummyService.new.call

        expect(redis).not_to have_received(:set)
      end
    end

    context 'with redis connection and no cache hit' do
      let(:cache) { nil }

      before do
        allow(DummyService).to receive(:redis) { redis }
        allow(redis).to receive(:get) { Marshal.dump(cache) }
        allow(redis).to receive(:set)

        stub_request(:get, 'https://www.google.com/').to_return(status: 200, body: '', headers: {})
      end

      it 'makes the http request' do
        DummyService.new.call

        expect(WebMock).to have_requested(:get, 'https://www.google.com')
      end
    end
  end
end
