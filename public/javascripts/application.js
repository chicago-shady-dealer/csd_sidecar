$( document ).ready( function() {
    $("section.volume h2").click(function() {
        var parentSection = $(this).parent().children("section.issues");
        parentSection.slideToggle('slow', function () {});
    });
});
