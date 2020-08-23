Gem::Specification.new do |s|
    s.name = 'anngler'
    s.version = '0.0.2'
    s.date = '2020-05-20'
    s.summary = 'Anngler is an approximate nearest neighbor search for points in n-dimensional space that are close in terms of cosine distance to a given point. The gem is built with serverless architecture in mind with Redis but it also offers a local in-memory storage.'

    s.authors = ['Aiden Leeming']

    s.add_development_dependency "rspec"
    s.add_development_dependency "mock_redis"
    s.add_development_dependency 'rake'
    s.add_development_dependency 'bundler'

    s.files = [
        'lib/anngler.rb',
        'lib/anngler/helpers.rb',
        'lib/anngler/storage/memory_backend.rb',
        'lib/anngler/storage/redis_backend.rb',
        'lib/anngler/index.rb'
    ]
    s.require_paths = ['lib']

    s.add_dependency 'json'
    s.add_dependency 'numo-narray'
    s.add_dependency 'redis'
    s.add_dependency 'zlib'
end
