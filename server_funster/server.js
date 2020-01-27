var path = require("path");
var fs = require('fs');
var mysql = require('mysql');
var express = require('express'),
app = express(),
port = process.env.PORT || 16003;

var bodyParser = require('body-parser')
app.use(bodyParser.json({limit: '10mb', extended: true}))
app.use(bodyParser.urlencoded({limit: '10mb', extended: true}))
app.use(express.static(path.join(__dirname, './media')));
app.use('/media', express.static(path.join(__dirname, './media')));

app.listen(port);
console.log('RESTful API server started on: ' + port);

var db_config = {
    host: "localhost",
    user: "root",
    password: "",
    database: "funster"
};

var con = mysql.createConnection(db_config);

function handleDisconnect() {
  con = mysql.createConnection(db_config);
  con.connect(function(err) {
    if(err) {
      console.log("error when connecting to db:" + err);
      setTimeout(handleDisconnect, 2000);
    }
  });
  con.on('error', function(err) {
    console.log("db error" + err);
    if(err.code === 'PROTOCOL_CONNECTION_LOST') {
        handleDisconnect();
    }
    else {
      throw err;
    }
  });
}
handleDisconnect();


app.get('/', function (req, res) {
	res.sendFile(path.join(__dirname + '/index.html'));  
})

//Media
app.post('/media/page/:page', function (req, res) {
	var page = req.params.page * 10;
	var user_id = req.params.user_id;
	
	con.query("SELECT M.id,M.link,M.thumbnail,M.text,M.type,COUNT(L.user_id) as likes,GROUP_CONCAT(L.user_id) as users_id_likes FROM funster.media as M LEFT JOIN funster.likes as L ON M.id = L.media_id GROUP BY M.id ORDER BY M.id DESC LIMIT ? , 10",[parseInt(page, 10)], function(err, rows) {
		res.send({media:rows});
	});

})
app.post('/media/add', function (req, res) {
	var type = req.body.type;
	var user_id = req.body.user_id;

	if(type == 0){
		var base64_video = req.body.base64_video;
		var base64_thumbnail = req.body.base64_thumbnail;
		var name_vid = Math.random().toString(36).substring(2);
		var name_thumb = Math.random().toString(36).substring(2);

		fs.writeFile("./media/" + name_vid + ".mov", base64_video, 'base64', function(err) {
		    if(err){
		        return res.send({status:false});
		    }
			else{
			    fs.writeFile("./media/" + name_thumb + ".jpg", base64_thumbnail, 'base64', function(err) {
				    if(err){
				        return res.send({status:false});
				    }
					else{
					    var link = "/media/" + name_vid + ".mov";
						var thumbnail = "/media/" + name_thumb + ".jpg";

						con.query("INSERT INTO media(type,link,thumbnail,user_id) VALUES(?,?,?,?)", [type,link,thumbnail,user_id], function(err) {
							if (err) {
								return res.send({status:false});
							}
							else{
								res.send({status:true});
							}
						});
					}
				});
			}
		});
	}
	else if(type == 1){
		var base64_image = req.body.base64_image;
		var name = Math.random().toString(36).substring(2);

		fs.writeFile("./media/" + name + ".jpg", base64_image, 'base64', function(err) {
		    if(err){
		        return res.send({status:false});
		    }
			else{
			    var link = "/media/" + name + ".jpg";

				con.query("INSERT INTO media(type,link,user_id) VALUES(?,?,?)", [type,link,user_id], function(err) {
					if (err) {
						return res.send({status:false});
					}
					else{
						res.send({status:true});
					}
				});
			}
		});
	}
	else if(type == 2){
		var text = req.body.text;

		con.query("INSERT INTO media(type,text,user_id) VALUES(?,?,?)", [type,text,user_id], function(err) {
			if (err) {
				return res.send({status:false});
			}
			else{
				res.send({status:true});
			}
		});
	}
})

//Administrator
app.post('/admin/users/page/:page', function (req, res) {
	var page = req.params.page * 10;
	con.query("SELECT * FROM users ORDER BY id DESC LIMIT ? , 10",[parseInt(page, 10)], function(err, rows) {
		res.send({users:rows});
	});
})
app.post('/admin/users/edit', function (req, res) {
	var user_id = req.body.user_id;
	var nickname = req.body.nickname;
	con.query("UPDATE users SET nickname = ? WHERE id = ?", [nickname,user_id], function(err) {
		if (err) {
			return res.send({status:false});
		}
		else{
			res.send({status:true});
		}
	});
})
app.post('/admin/users/remove', function (req, res) {
	var user_id = req.body.user_id;
	con.query("DELETE FROM users WHERE id = ?", [user_id], function(err, result) {
		if (err) {
			return res.send({status:false});
		}
		else{
			res.send({status:true});
		}
	});
})
app.post('/admin/media/page/:page', function (req, res) {
	var page = req.params.page * 10;
	con.query("SELECT * FROM media WHERE approved = 0 ORDER BY id DESC LIMIT ? , 10",[parseInt(page, 10)], function(err, rows) {
		res.send({media:rows});
	});
})
app.post('/admin/media/remove', function (req, res) {
	var media_id = req.body.media_id;

	con.query("DELETE FROM media WHERE id = ?", [media_id], function(err, result) {
		if (err) {
			return res.send({status:false});
		}
		else{
			res.send({status:true});
		}
	});
})
app.post('/admin/media/approve', function (req, res) {
	var media_id = req.body.media_id;

	con.query("UPDATE media SET approved = 1 WHERE id = ?", [media_id], function(err) {
		if (err) {
			return res.send({status:false});
		}
		else{
			res.send({status:true});
		}
	});
})

//Comments
app.post('/comments', function (req, res) {
	var media_id = req.body.media_id;
	var page = req.body.page * 10;

	con.query("SELECT * FROM comments as C JOIN users as U on C.user_id = U.id WHERE C.media_id = ? ORDER BY C.id DESC LIMIT ? , 10", [media_id,parseInt(page, 10)], function(err, rows) {
		res.send({comments:rows});
	});
})
app.post('/comments/add', function (req, res) {
	var comment = req.body.comment;
	var media_id = req.body.media_id;
	var user_id = req.body.user_id;

	con.query("INSERT INTO comments(comment,media_id,user_id) VALUES(?,?,?)", [comment,media_id,user_id], function(err) {
		if (err) {
			return res.send({status:false});
		}
		else{
			res.send({status:true});
		}
	});
})
app.post('/comments/edit', function (req, res) {
	var comment = req.body.comment;
	var comment_id = req.body.comment_id;

	con.query("UPDATE comments SET comment = ? WHERE id = ?", [comment,comment_id], function(err) {
		if (err) {
			return res.send({status:false});
		}
		else{
			res.send({status:true});
		}
	});
})
app.post('/comments/remove', function (req, res) {
	var comment_id = req.body.comment_id;

	con.query("DELETE FROM comments WHERE id = ?", [comment_id], function(err, result) {
		if (err) {
			return res.send({status:false});
		}
		else{
			res.send({status:true});
		}
	});
})

//like
app.post('/like', function (req, res) {
	var media_id = req.body.media_id;
	var user_id = req.body.user_id;
 
	con.query("INSERT INTO likes(media_id,user_id) VALUES(?,?)", [media_id,user_id], function(err) {
		if (err) {
			return res.send({status:false});
		}
		else{
			res.send({status:true});
		}
	});
})
app.post('/dislike', function (req, res) {
	var media_id = req.body.media_id;
	var user_id = req.body.user_id;
 
	con.query("DELETE FROM likes WHERE media_id = ? AND user_id = ?", [media_id,user_id], function(err, result) {
		if (err) {
			return res.send({status:false});
		}
		else{
			res.send({status:true});
		}
	});
})
app.post('/likes/:media_id', function (req, res) {
	var media_id = req.params.media_id;
	con.query("SELECT U.* FROM funster.likes as L JOIN funster.users as U ON L.user_id = U.id WHERE L.media_id = ?",[media_id], function(err, rows) {
		res.send({media:rows});
	});
})

//users
app.post('/login', function (req, res) {
	var email = req.body.email;
	var password = req.body.password;
	con.query("SELECT * FROM users WHERE email = ? AND password = ?",[email,password], function(err, rows) {
		if (err) {
			return res.send({status:false});
		}
		else{
			if(rows.length > 0){
				res.send({
					status:rows.length > 0 ? true : false,
					user_id:rows[0].id,
				});
			}
			else{
				res.send({status:false});
			}
		}
	});
})
app.post('/register', function (req, res) {
	var email = req.body.email;
	var password = req.body.password;
 	var nickname = email.split("@")[0];

	con.query("INSERT INTO users(email,password,nickname) VALUES(?,?,?)", [email,password,nickname], function(err) {
		if (err) {
			return res.send({status:false});
		}
		else{
			res.send({status:true});
		}
	});
})