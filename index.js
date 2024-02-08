const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

const { exec }  = require("child_process");
const SleepTime = require('./lib/sleeptime');
const NPS       = require('./lib/NoPollSubscriber_NODEJS.js');




// Sync:
let fs = require('fs');
let config = JSON.parse(fs.readFileSync('./config.json', 'utf8'));

let osUser = require("os").userInfo().username;
console.log("Running as:", osUser);
/*fs.writeFile('./user.txt', osUser, err => {
	if (err) {
		console.error(err);
	}
	// file written successfully
});*/


//Async:
/*let fs = require('fs');
let config;
fs.readFile('./config.json', 'utf8', function (err, data) {
	if (err) throw err;
	config = JSON.parse(data);
});*/











/* If the system idles for 5 seconds, reestablish connection. */
const sleepy = new SleepTime( (diff, date) => {
		console.log("System slept for " + Math.round(diff / 1000) + " seconds" + " and woke up at " + date);
		subscription.start();
	}, 5000);











function logToDb(deviceTargetId, logText) {

	fetch(config.pub_server + '?device=' + deviceTargetId + '&log=' + encodeURIComponent(logText), {
		headers: {'X-Auth-Bearer': config.client_id}
	})
		// .then( (res) => console.log("Logged to database.", logText) )
		// .then( (res) => res.json() )
		.then( (res) => res.text() )
		.then( (text) => console.log("response: ", text) )
		.catch( (err) => console.log("Failed to log.", err) )
}













// This uses an external application for clipboard access, so fill it in here
// Some options: pbcopy (macOS), xclip (Linux or anywhere with Xlib), clip (Windows)
const COPY_APP = 'clip'; // pbcopy/pbpaste (for OSX), xclip (for linux), and clip (for windows)

function copy(data, encoding='utf8') {
	const proc = require("child_process").spawn(COPY_APP, [], {/*uid: 0*/});
	proc.stdin.write(data, {encoding});
	// console.log(data, {encoding});
	// proc.stdin.write("data", {encoding: "text/html"}, "mid", "mid", "mid", "mid");
	proc.stdin.end();
}













function getLockscreenUsers() {
	// Know if session is locked (PC seeing lockscreen, no user logged in)

	/*
	exec("logonui", (error, stdout, stderr) => {
		if (error) {
			console.log(`error: ${error.message}`);
			return;
		}
		if (stderr) {
			console.log(`stderr: ${stderr}`);
			return;
		}
		console.log(`========== BEGIN LOGONUI OUT ==========`);
		console.log(`stdout:\r\n${stdout}`);
		console.log(`========== END LOGONUI OUT ==========`);

	});
	*/


	/*exec("tasklist", (error, stdout, stderr) => {
		if (error) {
			console.log(`error: ${error.message}`);
			return;
		}
		if (stderr) {
			console.log(`stderr: ${stderr}`);
			return;
		}
		console.log(`========== BEGIN LOGONUI OUT ==========`);
		// console.log(`stdout:\r\n${stdout}`);

		stdout.split(/\r\n/).forEach( (line) => {
			if (/LogonUI\.exe|logon\.scr/.test(line)) console.log(line);
		} );

		console.log(`========== END LOGONUI OUT ==========`);

	});*/


	return new Promise( (resolve, reject) => {

		/*
		In Windows 10, each loged-in user-session can have a "LogonUi.exe" process.
		If the session is not open, the process will be shown;
		if the session is open, the process will be killed
		*/
		exec('tasklist | findstr /c:"logon.scr" /c:"LogonUI.exe"', (error, stdout, stderr) => {
			if (error) {
				// Posiblemente no encontró ningún proceso con esos nombres.
				console.log(`error: ${error.message}`);
				// reject(error.message);
				resolve([]);
			}
			if (stderr) {
				console.log(`stderr: ${stderr}`);
				reject(stderr);
			}
			console.log(`stdout:\r\n${stdout}`);

			const userLockscreens = [];

			const outLines = stdout.split(/\r\n/);

			for (var i = 0; i < outLines.length-1; i++) {
				lineParts = outLines[i].split(/\s{2,}/);
				userId = lineParts[lineParts.length-2];

				userLockscreens.push(userId);
			}

			resolve(userLockscreens);

		});

	} );
	
}














function callbackOnParsed(data) {
	console.log('Received:', data);

	const res = JSON.parse(data);



	if (res.ep.emitted == "@SERVER@") {

		connId      = res.e.detail.connid;
		connSecret  = res.e.detail.secret;
		connTimeout = res.e.detail.timeout;

		begginAliveLoop();
	}



	if (res.e.type == 'pwrctrl') {

		subscription.stop();
		subscription.abort();

		if (osUser !== "SYSTEM") return; // This command can be run by SYSTEM, so don't run it under User

		if (res.e.detail.data == 'sleep') {

			exec("rundll32.exe powrprof.dll, SetSuspendState Sleep", (error, stdout, stderr) => {
				if (error) {
					console.log(`error: ${error.message}`);
					logToDb(res.e.detail.device, `error: ${error.message}`);
					return;
				}
				if (stderr) {
					console.log(`stderr: ${stderr}`);
					logToDb(res.e.detail.device, `stderr: ${stderr}`);
					return;
				}
				console.log(`stdout:\r\n${stdout}`);
				logToDb(res.e.detail.device, `Sleeping...`);
			});
		}

		if (res.e.detail.data == 'off') {

			exec("shutdown /p /f", (error, stdout, stderr) => {
				if (error) {
					console.log(`error: ${error.message}`);
					logToDb(res.e.detail.device, `error: ${error.message}`);
					return;
				}
				if (stderr) {
					console.log(`stderr: ${stderr}`);
					logToDb(res.e.detail.device, `stderr: ${stderr}`);
					return;
				}
				console.log(`stdout:\r\n${stdout}`);
				logToDb(res.e.detail.device, `Shutting down...`);
			});
		}

	}

	if (res.e.type == 'sessionlock') {

		if (osUser === "SYSTEM") return; // This command can't be run by SYSTEM, so run it under User

		exec("rundll32.exe user32.dll,LockWorkStation", (error, stdout, stderr) => {
			if (error) {
				console.log(`error: ${error.message}`);
				logToDb(res.e.detail.device, `error: ${error.message}`);
				return;
			}
			if (stderr) {
				console.log(`stderr: ${stderr}`);
				logToDb(res.e.detail.device, `stderr: ${stderr}`);
				return;
			}
			console.log(`stdout:\r\n${stdout}`);
			logToDb(res.e.detail.device, `Session locked`);

			// RETURN ACKNOWLEDGE

			fetch(`${config.pub_server}?device=${res.e.detail.device}&log=locking_session_ok`, {
				method: 'post',
				body: JSON.stringify( {
					type: "status",
					data: "locking session",
					whisper: res.e.detail.whisper
				} ),
				headers: {
					'Content-Type': 'application/json',
					'X-Auth-Bearer': config.client_id
				}
			})
				.then( (res) => res.text() )
				// .then( (res) => res.json() )
				.then( (data) => console.log(data) );
		});

	}

	if (res.e.type == 'mediactrl') {

		if (osUser === "SYSTEM") return; // This command can't be run by SYSTEM, so run it under User

		exec(`".\\res\\media_keys.exe" ${res.e.detail.data}`, (error, stdout, stderr) => {
			if (error) {
				console.log(`error: ${error.message}`);
				logToDb(res.e.detail.device, `error: ${error.message}`);
				return;
			}
			if (stderr) {
				console.log(`stderr: ${stderr}`);
				logToDb(res.e.detail.device, `stderr: ${stderr}`);
				return;
			}
			console.log(`stdout:\r\n${stdout}`);
			logToDb(res.e.detail.device, `Media action: ${res.e.detail.data}`);
		});

	}

	if (res.e.type == 'clipctrl') {

		if (osUser === "SYSTEM") return; // This command can't be run by SYSTEM, so run it under User

		// require('child_process').spawn('clip').stdin.end(res.e.detail||"");
		copy(res.e.detail.data.text);

		exec(`echo %username%`, (error, stdout, stderr) => {
			if (error) {
				console.log(`error: ${error.message}`);
				logToDb(res.e.detail.device, `error: ${error.message}`);
				return;
			}
			if (stderr) {
				console.log(`stderr: ${stderr}`);
				logToDb(res.e.detail.device, `stderr: ${stderr}`);
				return;
			}
			console.log(`stdout:\r\n${stdout}`);
			logToDb(res.e.detail.device, `Data in [${stdout}]'s clipboard: ${res.e.detail.data.text}`);
		});
	}

	if (res.e.type == 'popup') {

		if (osUser !== "SYSTEM") return; // This command can be run by SYSTEM, so don't run it under User

		console.log(res.e.detail)
		
		exec(`msg ${res.e.detail.data.user} \"${res.e.detail.data.message}\"`, (error, stdout, stderr) => {
			if (error) {
				console.log(`error: ${error.message}`);
				logToDb(res.e.detail.device, `error: ${error.message}`);
				return;
			}
			if (stderr) {
				console.log(`stderr: ${stderr}`);
				logToDb(res.e.detail.device, `stderr: ${stderr}`);
				return;
			}
			console.log(`stdout:\r\n${stdout}`);
			logToDb(res.e.detail.device, `Popup message to ${res.e.detail.data.user}: ${res.e.detail.data.message}`);
		});
	}

	if (res.e.type == 'applaunch') {

		if (osUser === "SYSTEM") return; // This command can't be run by SYSTEM, so run it under User

		if (res.e.detail.data == 'teamviewer') {

			exec('start "" "%ProgramFiles(x86)%\\TeamViewer\\TeamViewer.exe"', (error, stdout, stderr) => {
				if (error) {
					console.log(`error: ${error.message}`);
					logToDb(res.e.detail.device, `error: ${error.message}`);
					return;
				}
				if (stderr) {
					console.log(`stderr: ${stderr}`);
					logToDb(res.e.detail.device, `stderr: ${stderr}`);
					return;
				}
				console.log(`stdout:\r\n${stdout}`);

				// RETURN ACKNOWLEDGE

				fetch(`${config.pub_server}?device=${res.e.detail.device}&log=launching_app_teamviewer`, {
					method: 'post',
					body: JSON.stringify( {
						type: "status",
						data: "Starting TeamViewer",
						whisper: res.e.detail.whisper
					} ),
					headers: {
						'Content-Type': 'application/json',
						'X-Auth-Bearer': config.client_id
					}
				})
					.then( (res) => res.text() )
					// .then( (res) => res.json() )
					.then( (data) => console.log(data) );
			});
		}

	}

	if (res.e.type == 'sessioninfo') {

		if (osUser !== "SYSTEM") return; // This command can be run by SYSTEM, so don't run it under User

		getLockscreenUsers()
			.then( (lockscreenUsers) => {


			// query user == quser
			// query server == qwinsta

			exec("quser", (error, stdout, stderr) => {
				if (error) {
					console.log(`error: ${error.message}`);
					logToDb(res.e.detail.device, `error: ${error.message}`);
					return;
				}
				if (stderr) {
					console.log(`stderr: ${stderr}`);
					logToDb(res.e.detail.device, `stderr: ${stderr}`);
					return;
				}
				console.log(`stdout:\r\n${stdout}`);


				const sessionInfo = [];
				const outLines = stdout.split('\r\n');

				let infoTitles = [];
				let theIsAnArrowInSomeUser = false;

				for (let i = 0; i < outLines.length-1; i++) {

					if (i == 0) {
						// First line = titles
						infoTitles = outLines[i]
							.replace(/\./g, ' ')
							.replace(/\s{2,}/g, '|')
							.replace(/\s/g, '_')
							.split('|');

						if (infoTitles[0].charAt(0) == '_') theIsAnArrowInSomeUser = true; // If the first element start with "_" (previously a space) (it means one user is selected with ">" character)

						if (theIsAnArrowInSomeUser) infoTitles[0] = infoTitles[0].substring(1); // Trim the first character (it means one user is selected with ">" character)

					} else {

						const uSession = {};
						const uSessionData = outLines[i].split(/\s{2,}/);

						if (uSessionData.length < infoTitles.length) uSessionData.splice(1, 0, ""); // Insert (nothing) at the SESSION NAME index, if there is no SESSION NAME

						if (theIsAnArrowInSomeUser) uSessionData[0] = uSessionData[0].substring(1); // Trim the first character (it means one user is selected with ">" character)
						
						// If there is still no match, something changed! please debug
						if (uSessionData.length != infoTitles.length) {
							console.error("??? the command output changed ??? Can't parse data. Please debug.", "shell command: quser")
						}

						for (let i = 0; i < infoTitles.length; i++) {
							uSession[infoTitles[i]] = uSessionData[i];
						}

						uSession["LOCKED"] = false;
						if ( lockscreenUsers.includes(uSession["ID"]) ) {
							uSession["LOCKED"] = true;
						}

						sessionInfo.push(uSession);
					}
				}


				// RETURN SESSION INFO
				console.log( sessionInfo );

				fetch(`${config.pub_server}?device=${res.e.detail.device}&log=devolviendo_informacion_de_sesiones_activas_en_pc`, {
					method: 'post',
					body: JSON.stringify( {
						type: 'sessioninfo',
						data: sessionInfo,
						whisper: res.e.detail.whisper
					} ),
					headers: {
						'Content-Type': 'application/json',
						'X-Auth-Bearer': config.client_id
					}
				})
					.then( (res) => res.text() )
					// .then( (res) => res.json() )
					.then( (data) => console.log(data) )

			});

		} );

	}

	if (res.e.type == 'usersinfo') {

		if (osUser === "SYSTEM") return; // This command can't be run by SYSTEM, so run it under User

		exec("net user", (error, stdout, stderr) => {
			if (error) {
				console.log(`error: ${error.message}`);
				logToDb(res.e.detail.device, `error: ${error.message}`);
				return;
			}
			if (stderr) {
				console.log(`stderr: ${stderr}`);
				logToDb(res.e.detail.device, `stderr: ${stderr}`);
				return;
			}
			console.log(`stdout:\r\n${stdout}`);


			const usersInfo = [];
			const outLines = stdout.split('\r\n');

			for (let i = 0; i < outLines.length; i++) {

				if (i > 3 && i < outLines.length-3) { // Strip useless lines
					console.log(`${i}:`, outLines[i]);

					const usersInLine = outLines[i].split(/\s{2,}/);

					for (let i = 0; i < usersInLine.length; i++) {
						if (usersInLine[i] != "") usersInfo.push(usersInLine[i]);
					}
				}
			}


			// RETURN SESSION INFO
			console.log( usersInfo );

			fetch(`${config.pub_server}?device=${res.e.detail.device}&log=devolviendo_informacion_de_usuarios_registrados_en_pc`, {
				method: 'post',
				body: JSON.stringify( {
					type: "usersinfo",
					data: usersInfo,
					whisper: res.e.detail.whisper
				} ),
				headers: {
					'Content-Type': 'application/json',
					'X-Auth-Bearer': config.client_id
				}
			})
				.then( (res) => res.text() )
				// .then( (res) => res.json() )
				.then( (data) => console.log(data) )

		});

	}

	if (res.e.type == 'networkinfo') {

		if (osUser !== "SYSTEM") return; // This command can be run by SYSTEM, so don't run it under User

		exec("ipconfig /all", (error, stdout, stderr) => {
			if (error) {
				console.log(`error: ${error.message}`);
				logToDb(res.e.detail.device, `error: ${error.message}`);
				return;
			}
			if (stderr) {
				console.log(`stderr: ${stderr}`);
				logToDb(res.e.detail.device, `stderr: ${stderr}`);
				return;
			}
			console.log(`stdout:\r\n${stdout}`);


			const networkInfo = {};
			const outLines = stdout.split('\r\n');
			let currentAdapter = "";
			let lastKey = ""

			for (let i = 0; i < outLines.length; i++) {
				let line = outLines[i];

				if (line.length < 1) continue;

				if (line.substring(0,3) == "   ") {
					// line is content

					lineArr = line.split(" : ");
					contKey = lineArr[0];
					contVal = lineArr[1];

					if (contVal !== undefined) {
						// Clean key
						contKey = contKey.replace(/^\s+|(\.|\s)+(\s\.)+$/gm,'');
						networkInfo[currentAdapter][contKey] = contVal;
						lastKey = contKey;
					} else {
						if ( !Array.isArray(networkInfo[currentAdapter][lastKey]) ) {
							lkVal = networkInfo[currentAdapter][lastKey];
							networkInfo[currentAdapter][lastKey] = [lkVal];
						}

						networkInfo[currentAdapter][lastKey].push(contKey.replace(/^\s+/gm,''));
					}

				} else {
					// line is title

					// Clean line
					if (line[line.length-1] == ":") {
						line = line.substring(0, (line.length-1) );
					}

					currentAdapter = line;
					networkInfo[currentAdapter] = {};
				}

			}


			// RETURN NETWORK INFO
			console.log( networkInfo );

			fetch(`${config.pub_server}?device=${res.e.detail.device}&log=devolviendo_informacion_de_red`, {
				method: 'post',
				body: JSON.stringify( {
					type: "networkinfo",
					data: networkInfo,
					whisper: res.e.detail.whisper
				} ),
				headers: {
					'Content-Type': 'application/json',
					'X-Auth-Bearer': config.client_id
				}
			})
				.then( (res) => res.text() )
				// .then( (res) => res.json() )
				.then( (data) => console.log(data) )

		});

	}

	if (res.e.type == 'status') {

		// Run this command under any osUser!

		process.emit('eventtt', "aloo");

		const nodeStatus = {
			user: process.env['USERPROFILE'],
			cwd: process.cwd(),
			// egid: process.getegid(),
			// euid: process.geteuid(),
			// gid: process.getgid(),
			// uid: process.getuid(),
			pid: process.pid,
			ppid: process.ppid,
			title: process.title,

			memory: {}
		};

		const used = process.memoryUsage();
		for (let key in used) {
			nodeStatus.memory[key] = `${Math.round(used[key] / 1024 / 1024 * 100) / 100} MB`
		}

		console.log(nodeStatus);

		// RETURN SESSION INFO

		fetch(`${config.pub_server}?device=${res.e.detail.device}&log=devolviendo_status_de_servicio_en_windows`, {
			method: 'post',
			body: JSON.stringify( {
				type: "status",
				data: nodeStatus,
				whisper: res.e.detail.whisper
			} ),
			headers: {
				'Content-Type': 'application/json',
				'X-Auth-Bearer': config.client_id
			}
		})
			.then( (res) => res.text() )
			// .then( (res) => res.json() )
			.then( (data) => console.log(data) );
	}
	
}

function callbackOnSubscribe() {
	console.log('subscribed!');
}

function callbackOnStateChange(st) {
	console.log('state changed', st.value, st.state);

	// console.log(st);
	if (st.value == -1) {
		// document.getElementById('controll').style.border = "1px solid #607d8b"; // Offline
		notifyConnected = false;
	}

	if (st.value ==  0) {
		// document.getElementById('controll').style.border = "1px solid #f44336"; // Disconnected from subscription endpoint
		notifyConnected = false;
	}

	if (st.value ==  1) {
		// document.getElementById('controll').style.border = "1px solid #ffc107"; // Connecting
		notifyConnected = false;
	}

	if (st.value ==  2) {
		// document.getElementById('controll').style.border = "1px solid #cddc39"; // Connected
		notifyConnected = true;
	}
}

// process.on('eventtt', (ev) => {console.log(ev);})










let connId;
let connSecret;
let connTimeout;
let aliveLoop;
let notifyConnected;

function begginAliveLoop() {

	clearTimeout(aliveLoop);

	aliveLoop = setTimeout(function() {

		if (!notifyConnected) {
			clearTimeout(aliveLoop);
			return;
		}

		const refreshURL = `${config.sub_server}alive`;

		fetch(refreshURL, {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json'
			},
			body: JSON.stringify({connid: connId, secret: connSecret})
		})
			.then(response => response.json())
			.then(data => {
				connId      = data.connid;
				connSecret  = data.secret;
				connTimeout = data.timeout;
			})
			.catch(error => {
				console.error('Error on Alive request:', error);
				clearTimeout(aliveLoop);
			})

		begginAliveLoop();

	}, connTimeout - 3000); // timeout - 3 seconds
}














const subscription = new NPS({
		url: config.sub_server,
		method: 'POST',
		data: {
			clid: config.client_id,
			ep: [
				{
					topic: `controll/win_svc/${config.client_id}/req`,
					// binded: true
				}
			]
		}
	},
	callbackOnParsed,
	callbackOnSubscribe,
	callbackOnStateChange
);

// subscription.setBindingKeyUrl('https://estudiosustenta.com/test/session/bindUser');
subscription.start();
