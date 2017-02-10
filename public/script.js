$(document).ready(function () {
    var marker = window.btoa('0');
    var prefix = window.btoa('');
    var all_loaded = false;

    function load_more_entries() {
        $.get('/load/' + marker + '/' + prefix, function (data) {
            if (data) {
                $('#files').append(data);
                marker = $('#files tr:last td:first').html();
                console.log("new marker: ", marker);
                marker = window.btoa(marker);
            } else {
                all_loaded = true;
                $('#nomore').show();
                $('#loader').fadeOut();
            }
        });
    }

    function reload() {
        $('#nomore').hide();
        $('#files').empty();
        all_loaded = false;
        marker = window.btoa('0');
        load_more_entries();
    }

    reload();

    $.get('/versioning', function (value) {
        if (value) {
            $('#versioning').append(value);
        }
    });

    $("#prefix").keyup(function () {
        prefix = window.btoa(this.value);
        reload();
    });

    $(document).on('click', '.openmodal', function () {
        var key = $(this).attr('key');
        $('#versions').empty();
        $('#versionloader').show();
        $('#versions-modal').modal('show');
        $.ajax({
            url: key + "/versions",
            success: function (data) {
                if (data) {
                    $('#versionloader').fadeOut();
                    $('#versions').append(data);
                }
            }
        });
    });

    $(window).data('ajaxready', true).scroll(function () {
        if (all_loaded || $(window).data('ajaxready') == false)
            return;
        if ($(window).scrollTop() == $(document).height() - $(window).height()) {
            $(window).data('ajaxready', false);
            load_more_entries();
            $(window).data('ajaxready', true);
        }
    });
});
