# frozen_string_literal: true

require 'akeneo/service_base'

describe Akeneo::ServiceBase do
  let(:url) { 'http://akeneo.api' }
  let(:access_token) { 'access_token' }

  describe 'mixins' do
    it 'prepends the Cache module before the ServiceBase' do
      service_base_index = described_class.ancestors.index { |a| a == described_class }
      cache_index = described_class.ancestors.index { |a| a == Akeneo::Cache }

      expect(service_base_index > cache_index).to be(true)
    end
  end
end
