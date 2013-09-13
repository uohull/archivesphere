role :web, "as1stage.dlt.psu.edu"
role :app, "as1stage.dlt.psu.edu"
role :solr, "as1stage.dlt.psu.edu" # This is where resolrize will run
role :db,  "as1stage.dlt.psu.edu", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"
