# Description:
#   Handles Iris authorization requests
# 
# Commands:
#   hubot [b]conectar con iris[/b] - Sends the user a PM with an authorization token

IRIS_APP_ID = process.env.IRIS_APP_ID
IRIS_APP_TOKEN = process.env.IRIS_APP_TOKEN

module.exports = (bot) ->
	bot.respond /conectar?(me)?[\s]*(con|a)?[\s]*iris/i, (msg) ->
		nick = msg.message.user.user_nick.toLowerCase()

		bot.http('https://iris.taringo.xyz/api/v1/user/connect')
			.header('Content-Type', 'application/json')
			.header('X-App-Auth', IRIS_APP_ID + ' ' + IRIS_APP_TOKEN)
			.post(JSON.stringify({ nick })) (err, res, body) ->
				try
					data = JSON.parse(body)
				catch ex
					err = 'could not parse JSON response'

				if err
					console.log("error connecting Iris account: #{err}")
					msg.send('Estoy ocupada, intenta de nuevo en un rato')
					return

				if not data.success
					console.log("error connecting Iris account: #{data.error}")
					msg.send('No puedo conectar tu cuenta ahora, intenta después')
					return

				console.log("successful Iris connection")
				bot.adapter.taringa.user.send_pm nick, 'Acceso a Iris', """Hola #{nick}!

Estos son los datos que necesitas para acceder a Iris a través de tu cliente
IRC favorito:

- [b]Servidor:[/b] [img=https://k60.kn3.net/C/7/2/B/6/5/1C5.png] (puerto 6667)
- [b]Nick:[/b] #{nick}
- [b]Contraseña:[/b] #{data.token}

No respondas este mensaje. Si tienes alguna duda o sugerencia, contacta con @ny
Disfruta del chat!"""

