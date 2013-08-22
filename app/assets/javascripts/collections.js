function modal_collection_list(action, event){
    if(action == 'open'){
        $(".collection-list-container").css("visibility", "visible");
        $(".collection-list-container").css("display", "block");
    }
    else if(action == 'close'){
        $(".collection-list-container").css("visibility", "hidden");
        $(".collection-list-container").css("display", "none");
    }

    event.preventDefault();
}

$(document).ready(function() {
    // toggle button on or off based on boxes being clicked
    $(".batch_document_selector, .batch_document_selector_all, .batch_document_selector_none, #check_all").bind('click', function(e) {
        var n = $(".batch_document_selector:checked").length;
        if (n>0 || $('input#check_all')[0].checked) {
            $('.sort-toggle').hide();
        } else {
            $('.sort-toggle').show();
        }

    });
});

