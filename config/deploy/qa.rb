role :web, "as2qa.dlt.psu.edu"
role :app, "as2qa.dlt.psu.edu"
role :solr, "as2qa.dlt.psu.edu" # This is where resolrize will run
role :db,  "as2qa.dlt.psu.edu", :primary => true # This is where Rails migrations will run, gem "whenever" defaults
#role :db,  "your slave db-server here"
