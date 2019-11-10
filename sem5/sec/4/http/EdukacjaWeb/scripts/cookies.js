 $(document).ready(function() {
 //Modul odpowiedzialny za obsluge cookies
	$('.zamknijCookie').click(function() {

    var exdate=new Date();
    exdate.setDate(exdate.getDate() + 30);

    if (document.domain.indexOf('rekrutacja.pwr.wroc.pl') != -1) { 
        document.cookie = "cookieinfo=accept; expires="+exdate.toGMTString()+"; path=/; domain=" + document.domain;
        domain = 'edukacja.pwr.wroc.pl';
    } else {
        domain = document.domain;
    } 
    document.cookie = "cookieinfo=accept; expires="+exdate.toGMTString()+"; path=/; domain=" + domain;

    $("#cookiesInfo").hide();
    
	});


   if(getCookie("cookieinfo") == "accept"){
       return;
   } else if (navigator.cookieEnabled) {
       $("#cookiesInfo").show();
       return;
   } else {
       return;
   } 
   
 });
 
 function getCookie(name) {
  
  var nameCookie = name + "=";
  var cookieList = document.cookie.split(';');
  for(var i=0;i < cookieList.length;i++) {
    var c = cookieList[i];
    while (c.charAt(0)==' ') c = c.substring(1,c.length);
    if (c.indexOf(nameCookie) == 0) return c.substring(nameCookie.length,c.length);
  }
  return null;
  
} 

 function cookiebox(){
   $("div#cookiedialog").dialog({
          modal: true,
          resizable: false,
          draggable: false,
          width: 600,
          height: 200,
          autoOpen: false,
          buttons: {
              "Zamknij": function() {
                  $( this ).dialog( "close" );
              }
          }
      });
  $("div#cookiedialog").show();
  $("div#cookiedialog").dialog('open');
  
  var info = "<h2>Czym są pliki „cookies” (inaczej „ciasteczka”)?</h2>"
  $("div#cookiedialog").text(info);
  
}
