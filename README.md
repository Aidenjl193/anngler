# Anngler

Anngler is an approximate nearest neighbor search for points in n-dimensional space that are close in terms of cosine distance to a given point. The gem is built with serverless architecture in mind with Redis but it also offers a local in-memory storage.

### Installation

Add Anngler to your gemfile:
```ruby
gem 'anngler'
```

And then run:
```sh
$ bundle
```

### Code Example
```ruby
require "anngler"

# create an index with 7 random projections for 30 dimensional vectors
index = Anngler::Index.new("bucket_name", 7, 30)

# add a point to the index
# labels allow you to attach data such as model IDs to the vector
vec = Numo::DFloat.new(30).rand
index.add(vec, label: "label_name")

# query the index (this will return all of the vectors hashed into the same bucket)
index.query(vec)
# [{"label"=>"label_name", "vec"=>Numo::DFloat#shape=[30][-0.276791, 0.828535, 0.010036, 0.874997, -0.169577, -0.0180099, 0.266599, ...]}]
```

### Features
#### Forests
When creating an index Anngler allows you to specify n_trees (this value is defaulted to 1), increasing this value allows for higher precision queries but will also result in potentially slower search times especially if you are using Redis as it does an n_trees amount of queries to Redis.
```ruby
index = Anngler::Index.new("bucket_name", 7, 30, n_trees: 3)
```

#### Redis
Setting up Anngler to use redis is easy, you just have to set up a redis backend, link it to your redis instance and then create an index with the specified backend.
```ruby
require "redis"

# connect to Redis
redis = Redis.new(url: "redis://:p4ssw0rd@10.0.1.1:6380/15")

# create a the redis backend
storage = Anngler::Storage::RedisBackend(redis)

index = Anngler::Index.new("bucket_name", 7, 30, storage: storage)
```
