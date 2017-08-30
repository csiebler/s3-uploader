$(document).ready(function () {
    var marker = window.btoa('0');
    var prefix = window.btoa('');
    var all_loaded = false;
    var finished_loading = true;

    function load_more_entries() {
        if (!finished_loading) {
            return;
        }
        finished_loading = false;
        $('#loader').show();
        console.log("Updating entries");
        $.get('/load/' + marker + '/' + prefix, function (data) {
            if (data) {
                $('#files').append(data);
                marker = $('#files tr:last td:first').html();
                console.log("New Marker: ", marker);
                marker = window.btoa(marker);
            } else {
                all_loaded = true;
                $('#nomore').fadeIn();
            }
            finished_loading = true;
            $('#loader').fadeOut();
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

    $("#prefix").keyup($.debounce(500 ,function () {
        prefix = window.btoa(this.value);
        reload();
    }));


    $(document).on('click', '.openmodal', function () {
        console.info("clicked");
        var key = $(this).attr('key');
        $('#versions').empty();
        $('#versionloader').show();
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

    $(window).scroll(function () {
        if (all_loaded || finished_loading == false)
            return;
        if ($(window).scrollTop() == $(document).height() - $(window).height()) {
                load_more_entries();
        }
    });
});
