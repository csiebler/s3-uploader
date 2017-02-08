$(document).ready(function () {
    var marker = '0';
    var all_loaded = false;

    $.get('/load/' + marker, function (data) {
        if (data) {
            $('#files > tbody:last-child').append(data);
            marker = $('#files tr:last td:first').html();
        }
    });

    $(window).data('ajaxready', true).scroll(function () {
        if (all_loaded || $(window).data('ajaxready') == false)
            return;

        console.log("scroll triggered");
        if ($(window).scrollTop() == $(document).height() - $(window).height()) {
            $(window).data('ajaxready', false);
            marker = $('#files tr:last td:first').html();
            $.ajax({
                url: "load/" + marker,
                success: function (data) {
                    if (data) {
                        $('#files > tbody:last-child').append(data);
                    } else {
                        $('#loader').fadeOut();
                        all_loaded = true;
                    }
                }
            });
            $(window).data('ajaxready', true);
        }

    });
});
