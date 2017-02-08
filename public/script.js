$(document).ready(function () {
    var marker = '0';

    $("#loadmore").click(function () {
        if (!$('#loadmore').hasClass('disabled')) {
            $.get('/load/' + marker, function (data) {
                if (data) {
                    $('#files > tbody:last-child').append(data);
                    marker = $('#files tr:last td:first').html();
                } else {
                    $('#loadmore').addClass('disabled');
                }
            });
        };
    });

    $("#loadmore").click();
});