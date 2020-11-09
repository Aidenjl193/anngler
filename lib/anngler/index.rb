require 'json'
require 'base64'
require 'zlib'
require "numo/narray"

module Anngler
    class Index
        #the number of features of the vectors we are storing
        attr_reader :n_features

        #the number of projections to generate (more = less vectors per bucket)
        attr_reader :n_projections

        #seed for our random number generator, we ensure this is deterministic buy resorting to the base16 of the bucket name if no seed is provided
        attr_reader :seed

        #the name of the bucket to allow multiple different hash tables in redis
        attr_reader :bucket_name

        #the random number generator for the projection matrices
        attr_reader :rng

        #an n_trees x n_features x n_projections matrix to store our projections
        attr_reader :trees

        #how many different projections to overlap (more allows for better accuracy but will slow performance)
        attr_reader :n_trees

        #which storage service to use (either redis or local memory)
        attr_reader :storage

        def initialize(
                bucket_name,
                n_projections,
                n_features,
                seed: nil,
                n_trees: 1,
                storage: Anngler::Storage::MemoryBackend.new
            )
            @n_projections = n_projections
            @n_features = n_features
            @seed = seed
            @seed ||= bucket_name.to_i(36)
            @bucket_name = bucket_name
            @rng = Random.new(@seed)
            @n_trees = n_trees
            @storage = storage

            gen_trees
        end

        def add(vec, label: "")
            hashes = calc_hashes(vec)
            #Serialize the vector and the label
            serialized_data = pack_data(vec, label)

            #add the vector into each tree
            hashes.each_with_index do |hash, i|
                bucket = "#{@bucket_name}:#{i}:#{hash2string(hash)}"
                @storage.add_vector(bucket, serialized_data)
            end
        end

        def remove(vec, label: "")
            hashes = calc_hashes(vec)

            #remove vector from each tree
            hashes.each_with_index do |hash, i|
                bucket = "#{@bucket_name}:#{i}:#{hash2string(hash)}"
                @storage.remove_vector(bucket, pack_data(vec, label))
            end
        end

        def query(vec)
            hashes = calc_hashes(vec)
            raw_results = []

            #search each tree and append the results into raw_results
            hashes.each_with_index do |hash, i|
                bucket = "#{@bucket_name}:#{i}:#{hash2string(hash)}"
                raw_results += @storage.query_bucket(bucket)
            end

            #remove duplicates and decode the data
            raw_results.uniq.map do |encoded_data|
                unpack_data(encoded_data)
            end.sort_by do |data|
                #sort the results by cosine distance
                Helpers.cosine_distance(vec, data["vec"])
            end
        end

        private

        def gen_trees
            vals = Array.new(@n_trees * @n_features * @n_projections) { (@rng.rand * 2) -1 }
            @trees = Numo::DFloat.asarray(vals).reshape(@n_trees, @n_features, @n_projections)
        end

        #return a hash key for each tree
        def calc_hashes(vec)
            (0..@n_trees - 1).map do |i|
                vec.dot(@trees[i, true, true]).ge(0.0)
            end
        end

        #turn the vector into a hexadecimal string
        def hash2string(hash)
            hash.to_a.join.to_i(2).to_s(16)
        end

        def encode_vec(vec)
            Base64.encode64(Zlib::Deflate.deflate(vec.to_a.join(",")))
        end

        def decode_vec(vec)
            Numo::DFloat.asarray(Zlib::Inflate.inflate(Base64.decode64(vec)).split(",").map(&:to_f))
        end

        def pack_data(vec, label)
            "#{encode_vec(vec)}:#{label}"
        end

        def unpack_data(encoded_data)
            encoded_vector, label = encoded_data.split(":")
            { "label" => label, "vec" => decode_vec(encoded_vector) }
        end
    end
end
