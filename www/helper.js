// handler when a SNP id link is clicked
function clickSNP(x) {
  Shiny.onInputChange('snpIDClicked', x);
  //window.location.href = '#drilldownAnchor';
  $('html, body').scrollTop( $(document).height() );
}

// This function will look for all elements with attribute "data-proxy-click",
// look at the value of the attribute, and simulate event of a control that
// has id = value of the attribute when user type "Enter" when focus on that
// control. Useful to tie together text box with action button where user 
// expects to hit "Enter" after typing value of the text box.
$(function() {
  var $els = $("[data-proxy-click]");
  $.each(
    $els,
    function(idx, el) {
      var $el = $(el);
      var $proxy = $("#" + $el.data("proxyClick"));
      $el.keydown(function (e) {
        if (e.keyCode == 13) {
          $proxy.click();
        }
      });
    }
  );
});