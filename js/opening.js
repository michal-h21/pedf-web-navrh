var opening = (function(calendarfile,basemsg){
  var getDate = function(today){
    var month = today.getMonth()+1;
    var day = today.getDate();
    return today.getFullYear() + "-" + (month < 10 ? "0"+month : month) + "-" + (day < 10 ? "0"+day:day);
    
  };
  var getMsg = function(today, dates){
    var todayfmt = getDate(today)
    return dates[todayfmt];
  }
  var addMsg = function(msg){
    var hello = document.querySelector("#closed");
    var clone = hello.cloneNode(true);
    clone.innerHTML = msg;
    hello.parentNode.replaceChild(clone, hello);
  }

  var xhr= new XMLHttpRequest();
  xhr.open("GET", calendarfile);
  xhr.responseType = "json";
  xhr.onload = function(){
    var dates = xhr.response;
    var today = new Date();
    var msg = getMsg(today, dates);
    if(msg){
      addMsg("<div><b>"+ basemsg + "</b></div><div>" +msg + "</div>");
    }else{
      addMsg("");
    }
  };
  xhr.send(null);
}
);


