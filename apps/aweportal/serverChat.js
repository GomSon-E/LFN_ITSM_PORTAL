//frameChat을 grpid로 여러 창을 띄우는 반면, dataSet 중복 문제로 다른 프레임에서 데이터 import 및 output이 불가능
//채팅 리스트 클릭 시, 방 입장과 함께 frameChat 페이지를 리턴하는 방식?-> 데이터셋을 통해 데이터를 채우고 뿌리는 방법에서 문제 발생하는 듯함

//-> 모두해결(dataset 문제가 아님)
//하나의 frameset으로 여러 채팅방을 생성했을 때, form submit 처리가 동시에 일어남 -> submit jQuery 태그에서 page.find() 사용으로 해결
//server에서 각 group으로 메세지 전달 시, 각 frameset이 group grpid를 구분하지 못하고 전부 append한 문제 -> grpid체크로 해결

//express
var app     = require("express")();

//http
var server  = require("http").createServer(app);

//socket.io
var socket  = require('socket.io');

//cors setting - origin에서의 요청만 처리(추후 지정)
var io      = socket(server, {
  cors : { origin  : "*", 
           methods : ["GET", "POST"] 
          }
});

//messages
var messages = io.of("/chat").on("connection", function(socket) {
  socket.on("chat", function(data) {

    console.log("client: ", data);

    //group - message를 전달할 group 지정
    var group = socket.group = data.grpid; 

    //join - group에 join
    socket.join(group);

    //to(group)으로 emit(message)를 "chat"에 data로 전송
    messages.to(group).emit("chat", data);
  });
});

//Run server(listen)
server.listen(8070, function() {
  console.log("Running Messenge server from port 8070");
});