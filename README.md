archivesphere
=============

Repository for storing digital archived materials originating from media

# Getting started

### Run the migrations

```
rake db:create
rake db:migrate
```
### (Re-)Generate the app's secret token

```
rake archivesphere:generate_secret
```

### Get a copy of hydra-jetty
```
rails g hydra:jetty
rake jetty:config
rake jetty:start
```

