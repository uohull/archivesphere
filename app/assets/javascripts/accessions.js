function toggle_accession_type(select) {
  if (select) {
    if (select.value == "Virtual Transfer"){
        $(".virtual-transfer").show();
        $(".disk-image").hide();
    } else {
        $(".virtual-transfer").hide();
        $(".disk-image").show();
    }
  }
}
$( document ).ready(function() {
  $("#accession_table").treetable( { expandable: true });
  $("#collection_accession_type").change(function(){
      toggle_accession_type(this);
  });
  toggle_accession_type($("#collection_accession_type")[0])
});

