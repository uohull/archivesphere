def create_base_collection_accession
  visit '/'
  click_on "Create Collection"
  fill_in "Name", with: "A Test Collection"
  click_button "Create Collection"
  fill_in "collection_accession_num", with: "Test #1234"
  click_button "Create Accession"
end