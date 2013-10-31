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

function toggle_batch_sort() {
    var n = $(".batch_document_selector:checked").length;
    if (n>0 || (($('input#check_all').length>=1) && $('input#check_all')[0].checked)) {
        $('.sort-toggle').hide();
        $('.batch-toggle').show();
    } else {
        $('.sort-toggle').show();
        $('.batch-toggle').hide();
    }

}

$(document).ready(function() {
    toggle_batch_sort();

    // toggle button on or off based on boxes being clicked
    $(".batch_document_selector, .batch_document_selector_all, .batch_document_selector_none, #check_all").bind('click', function(e) {
        toggle_batch_sort();

    });

    // change the action based which collection is selected
    $('#hydra-collection-add').on('click', function() {

        var form = $(this).closest("form");
        var collection_id = $(".collection-selector")[0].value;
        form[0].action = form[0].action.replace("collection_replace_id",collection_id);

    });


});

