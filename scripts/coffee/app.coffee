$ ->
  xmlRequest = $.ajax({
    url: "/USBuildings.xml",
    dataType: "xml"
  }).done (msg) ->
    $("body").html msg.find("Name")
