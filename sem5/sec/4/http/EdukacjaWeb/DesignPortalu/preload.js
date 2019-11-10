function infobox(el, msg){
  $("#helpdialog").dialog('open');
  $("#helpdialog").dialog('option', 'position', "center");
  $("#helpdialog").text(msg);
}

$(document).ready(function(){
    $("#helpdialog").dialog({ autoOpen: false, resizable: false, width: 300});
  });

function isIE(){
    return /msie/i.test(navigator.userAgent) && !/opera/i.test(navigator.userAgent);
}

function getPosition(element) {
    var aTag = element;
    leftpos = 0;
    toppos = 0;
    while(aTag && aTag.tagName!="BODY") {
        aTag = aTag.offsetParent;
        if (aTag) {
            leftpos += aTag.offsetLeft;
            toppos += aTag.offsetTop;
        }
    }
    leftpos = element.offsetLeft + leftpos + element.offsetWidth + 10;
    toppos = element.offsetTop + toppos + 10;
    return new Array(leftpos, toppos);
}

function preloadImages(path){
 	if (document.images) 
	{
		img1 = new Image();
		img1.src = path;
		return img1;
	};
}

function Obrazki(){

imgTab=new Array();
imgTab[imgTab.length]=(preloadImages("DesignPortalu/tlo01.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/li-middle.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/cl_tytul01.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/zakladka2_le.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/zakladka2_pr.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/zakladka2_sr.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/zakladka_akt2_le.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/zakladka_akt2_pr.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/zakladka_akt2_sr.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/kreska_g.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/kreska_d.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/linia.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/logowanie.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/zalogowany.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/b_zaloguj.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/b_zapomnialem_h.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/dostopcje.gif"));

//imgTab[imgTab.length]=(preloadImages("DesignPortalu/b_szukaj.gif"));
//imgTab[imgTab.length]=(preloadImages("DesignPortalu/cl_logo.gif"));
//imgTab[imgTab.length]=(preloadImages("DesignPortalu/wyszukiwarka.gif"));
//imgTab[imgTab.length]=(preloadImages("DesignPortalu/data.gif"));

imgTab[imgTab.length]=(preloadImages("DesignPortalu/guzik_nieakt.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/guzik_akt.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/guzik_rozw_gora.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/guzik_rozw_srodek_akt.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/guzik_rozw_srodek.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/guzik_rozw_dol.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/b_home.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/b_print.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/b_zmien_haslo.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/b_wyloguj.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/b_wiadomosc.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/b_wiadomosc_wyslij.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/ps.gif"));
imgTab[imgTab.length]=(preloadImages("DesignPortalu/tytul01.gif"));
}

Obrazki();
