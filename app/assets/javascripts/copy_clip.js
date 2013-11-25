$(document).ready(function() {
    ZeroClipboard.setDefaults({ moviePath: "/assets/ZeroClipboard.swf" });
    $.each($(".copypaste"), function() {
        var clip = new ZeroClipboard();
        clip.on("dataRequested", function(client, args) {
            clip.setText(getSingleUse(this.id));
        })
        clip.on("complete", function(client, args) {
            alert("A single use link to " + args.text + " was copied to your clipboard.")
        })
        clip.on("noflash", function(client, args) {
            alert("Your single-use link: " + getSingleUse(this.id))
        })
        clip.on("wrongflash", function(client, args) {
            alert("Your single-use link: " + getSingleUse(this.id))
        })
        clip.glue($("#" + this.id))
    })
});
