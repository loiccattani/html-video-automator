// A click on a tr toggle the ckeckbox's state
$(document).ready(function() {
  $('#dropbox tr.video')
    .filter(':has(:checkbox:checked)')
    .addClass('selected')
    .end()
  .click(function(event) {
    $(this).toggleClass('selected');
    if (event.target.type !== 'checkbox' && event.target.nodeName !== 'LABEL') {
      $(':checkbox', this).attr('checked', function() {
        return !this.checked;
      });
    }
  });
});
