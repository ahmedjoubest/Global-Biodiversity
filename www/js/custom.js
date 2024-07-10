
// Custom message handler for removing a leaflet layer
Shiny.addCustomMessageHandler(
    'removeleaflet',
    function(x) {
      console.log('Deleting layer with ID:', x.layerid);
      // get leaflet map
      var map = HTMLWidgets.find('#' + x.elid).getMap();
      // remove the specified layer
      if (map._layers[x.layerid]) {
        map.removeLayer(map._layers[x.layerid]);
      }
    }
  );

// Function to set the width of pickerInput
function setPickerWidth() {
    $('.bootstrap-select .dropdown-menu').each(function() {
        var picker = $(this).closest('.bootstrap-select');
        var width = picker.width();
        $(this).css('width', width + 'px');
        $(this).css('min-width', 'auto');
    });
}
// Run the function once on load
$(document).ready(function() {
    setPickerWidth();
});
// Run the function on window resize
$(window).resize(function() {
    setPickerWidth();
});
