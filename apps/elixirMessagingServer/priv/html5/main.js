window.onload = function() {

var game = new Phaser.Game(800, 600, Phaser.AUTO, 'Html5Client', 
    { preload: preload, create: create, update: update, render: render });

function preload() {
    try {
      console.log('Loading textures');
      //  We load a TexturePacker JSON file and image and show you how to make several unique sprites from the same file
      game.load.atlas('iso-outside', 'resources/iso-64x64-outside.png', 'resources/iso-64x64-outside.json');
      game.load.spritesheet('button', 'resources/button_sprite_sheet.png', 193, 71);
      //game.load.image('block', 'resources/block.png');
    } catch(exception) {
      console.log('Error:' + exception);
    }
};

var ProtoBuf = dcodeIO.ProtoBuf;
var builder = ProtoBuf.loadProtoFile("CommsMessages.proto");
var CommsMessages = builder.build("CommsMessages");
var clientId = 0;
var webServerId = 1000;
var socket;

var text;
var button;
var x = 32;
var y = 80;
var cursors;
var fireButton;



function create() {

    //  Modify the world and camera bounds
    // game.world.setBounds(-2000, -2000, 4000, 4000);
    game.world.resize(2000, 2000);
    
    game.stage.backgroundColor = '#404040';

    cursors = game.input.keyboard.createCursorKeys();
    fireButton = game.input.keyboard.addKey(Phaser.Keyboard.SPACEBAR);
    
    //	Just to kick things off
    button = game.add.button(200, 100, 'button', start, this, 2, 1, 0);

    //	Progress report
    text = game.add.text(32, 128, 'Click to login', { fill: '#ffffff' });
};


function start() {
    //  We load a TexturePacker JSON file and image and show you how to make several unique sprites from the same file
    //game.load.image('picture1', 'assets/pics/mighty_no_09_cover_art_by_robduenas.jpg');
    
    connect();

    // TODO - wait for open state, then send these
    setTimeout(function () {
      say("Hello World!");
      getMap(1,1);
    }, 20000);
    
    button.visible = false;
};

function update() {
    //  Scroll the background
    //starfield.tilePosition.y += 2;

    if (cursors.up.isDown)
    {
         game.camera.y -= 4;
    }
    else if (cursors.down.isDown)
    {
        game.camera.y += 4;
    }

    if (cursors.left.isDown)
    {
        game.camera.x -= 4;
    }
    else if (cursors.right.isDown)
    {
        game.camera.x += 4;
    }

        //  Run collision
    //    game.physics.arcade.overlap(bullets, aliens, collisionHandler, null, this);
    //    game.physics.arcade.overlap(enemyBullets, player, enemyHitsPlayer, null, this);
}

function render() {
    
    game.debug.cameraInfo(game.camera, 32, 32);
    
    // for (var i = 0; i < aliens.length; i++)
    // {
    //     game.debug.body(aliens.children[i]);
    // }

}

//var socket = new WebSocket("ws://localhost:8000/socket/server/startDaemon.php");
//
//socket.onopen = function(){
    //console.log("Socket has been opened!");
//}
//socket.onmessage = function(msg){
    //console.log(msg);
//}

/**
 * Creates a new Uint8Array based on two different ArrayBuffers
 *
 * @private
 * @param {ArrayBuffers} buffer1 The first buffer.
 * @param {ArrayBuffers} buffer2 The second buffer.
 * @return {ArrayBuffers} The new ArrayBuffer created out of the two.
 */
var _appendBuffer = function(buffer1, buffer2) {
  var tmp = new Uint8Array(buffer1.byteLength + buffer2.byteLength);
  tmp.set(new Uint8Array(buffer1), 0);
  tmp.set(new Uint8Array(buffer2), buffer1.byteLength);
  return tmp;//.buffer;
};

function connect() {
    try {
        var host = "ws://zen:8081";// /socket/server/startDaemon.php";
        socket = new WebSocket(host);
        socket.binaryType = "arraybuffer"; // or assign to "blob"

        console.log('Socket Status: '+socket.readyState);

        socket.onopen = function() {
            console.log('Socket Status: '+socket.readyState+' (open)');
            login(socket);
        };

        socket.onmessage = function(msg) {
            if (typeof msg.data === "string"){
              console.log("Received Text data from the server: " + msg.data);
            } else if (msg.data instanceof Blob){
              console.log("Received Blob data from the server");
            } else if (msg.data instanceof ArrayBuffer){
              console.log("Received ArrayBuffer data from the server");
              var array = new Uint8Array(msg.data);
              var protoMsgLen = array[0];
              var data = array.slice(protoMsgLen+1);
              var message = CommsMessages.Message.decodeDelimited(msg.data);
              console.log('Received msgtype: '+message.msgtype);
              if (message.msgtype === 1) {
                processResponse(message);
              } else if (message.msgtype === 9) {
                processMap(message, data);
              }        
            }
        };

        socket.onclose = function() {
            console.log('Socket Status: '+socket.readyState+' (Closed)');
        };          
    } catch(exception) {
        console.log('Error'+exception);
    }
}

function sendMessage(message) {
  console.log("Preparing to send message");
  var msg = new Uint8Array(message.encodeDelimited().toArrayBuffer());
  console.log("Sending:"+msg[0]+","+msg[1]+","+msg[2]);
  socket.send(msg);
  console.log("Message Sent");
}  

function login(socket) {
    try {
        console.log('Login...');
        var msg = new CommsMessages.Message({"msgtype":5, "from":clientId, "dest":webServerId });
        msg.login = new CommsMessages.Login({"username":"sean", "password":"pass"});

        sendMessage(msg);
        //var data = msg.encodeDelimited().toArrayBuffer();
        //socket.send(data);

    } catch(exception) {
       console.log('Error:' + exception);
    }
}

    var sprites = [
      "null", // 0
      "grass_slope_n.png",  // 1
      "grass_slope_ne.png", // 2
      "grass_slope_nw.png", // 3
      "grass_slope_e.png",  // 4
      "grass_block.png",    // 5
      "grass_slope_w.png",  // 6
      "grass_slope_se.png", // 7
      "grass_slope_sw.png", // 8
      "grass_slope_s.png",  // 9
      "grass_slope_wse.png",// 10
      "grass_slope_nws.png",// 11
      "grass_slope_wne.png",// 12
      "grass_slope_nes.png",// 13
      "rock_outcrop_.png",  // 14
      "rock_slope_n.png",   // 15
      "rock_slope_nw.png",  // 16
      "rock_slope_e.png",   // 17
      "rock_block_1.png",   // 18
      "rock_block_2.png",   // 19
      "rock_slope_w.png",   // 20
      "rock_slope_se.png",  // 21
      "rock_slope_sw.png",  // 22
      "rock_slope_s.png"   // 23
    ];

function processResponse(msg) {
    if (msg.response.code === 1) {
        clientId = msg.dest;
        console.log('Logged in, clientId = '+clientId);
    }
}
function processMap(msg, data) {
    console.log('Map message recevied');
    var idx=0;
    for (var x=0; x<10; x++){
        for (var y=0; y<10; y++){
            var colMin=data[idx++];
            var colMax=data[idx++];
            for (var z=colMin; z<=colMax; z++){
                var spr=sprites[data[idx++]];
                var block = game.add.sprite(400+(x-y)*32,256+(x+y)*16-z*21, 'iso-outside');
                //console.log('frameName: ' + x + ',' + y + '=' + mapsprites[y*10+x] + '=>' + sprites[mapsprites[y*10+x]])
                block.frameName = spr;
                block.anchor.setTo(0.5, 0.5);
            }
        }
    }
}

function say(text) {
    try {
        console.log('Say...');
        var msg = new CommsMessages.Message({"msgtype":6, "from":clientId, "dest":webServerId });
        msg.say = new CommsMessages.Say({"text":text});
        sendMessage(msg);
        //var data = msg.encodeDelimited().toArrayBuffer();
        //socket.send(data);
    } catch(exception) {
       console.log('Error:' + exception);
    }
}

function getMap(x,y) {
    try {
        console.log('GetMap...');
        var msg = new CommsMessages.Message({"msgtype":7, "from":clientId, "dest":webServerId });
        msg.mapRequest = new CommsMessages.MapRequest({"x":x, "y":y});
        sendMessage(msg);
        //var data = msg.encodeDelimited().toArrayBuffer();
        //socket.send(data);
    } catch(exception) {
       console.log('Error:' + exception);
    }
}

//socket.close();
}