$( document ).ready( function() {
    $("section.volume h2").click(function() {
        var parentSection = this.parent()
        parentSection.slideToggle('slow', function () {});
    });
});
