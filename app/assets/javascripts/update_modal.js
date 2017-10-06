$( document ).ready(function() {
  var identifiers = ['artist', 'label']

  $.each(identifiers, function(index, identifier) {
    var identifier = $('#' + identifier)

    identifier.on('click', function() {
      var identifierId = $(this).attr('id');
      var identifierModal = $('.modal.modal-' + identifierId);

      identifierModal.modal('show');

      identifierModal.on('hidden.bs.modal', function (e) {
        var select = $( this ).find('select').selectize();
        var selectize = select[0].selectize;
        selectize.clear(true);
      });

      identifierModal.find('form').on('submit', function(e) {
        e.preventDefault();

        var form = $(this);
        var entityId = form.find('select option:selected').val();

        $.ajax({
          method: 'PUT',
          dataType: "JSON",
          url: form.attr('action'),
          data: form.serialize(),
          success: function(data) {
            var reference = identifierId + '_name'
            var identifierValue = data[reference]

            identifier.closest('dd').text(identifierValue);
            identifierModal.modal('hide');
          }
        });
      });
    });
  });
});
