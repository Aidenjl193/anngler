require 'spec_helper'
require 'numo/narray'
require 'mock_redis'

describe Anngler do
    let(:bucket_name) { "test" }
    let(:n_projections) { 10 }
    let(:n_features) { 30 }
    let(:rng) { Random.new(1) }

    context "when using memory backend" do
        let(:index){ Anngler::Index.new(bucket_name, n_projections, n_features) }

        it "stores keys correctly" do
            vals = Array.new(n_features) { rng.rand }
            vec = Numo::DFloat.asarray(vals)
            index.add(vec, label: "test")
            expect(index.query(vec).map{ |res| res["label"] }).to include("test")
        end
    
        it "removes keys correctly" do
            vals = Array.new(n_features) { rng.rand }
            vec = Numo::DFloat.asarray(vals)
            index.add(vec, label: "test")
            index.remove(vec)
            expect(index.query(vec).map{ |res| res["label"] }).not_to include("test")
        end
    end

    context "when using redis backend" do
        let(:storage) { Anngler::Storage::RedisBackend.new(MockRedis.new) }
        let(:index){ Anngler::Index.new(bucket_name, n_projections, n_features, storage: storage) }

        it "stores keys correctly" do
            vals = Array.new(n_features) { rng.rand }
            vec = Numo::DFloat.asarray(vals)
            index.add(vec, label: "test")
            expect(index.query(vec).map{ |res| res["label"] }).to include("test")
        end
    
        it "removes keys correctly" do
            vals = Array.new(n_features) { rng.rand }
            vec = Numo::DFloat.asarray(vals)
            index.add(vec, label: "test")
            index.remove(vec)
            expect(index.query(vec).map{ |res| res["label"] }).not_to include("test")
        end
    end

end