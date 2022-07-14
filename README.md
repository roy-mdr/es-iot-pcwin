# es-iot-pcwin

Estudio Sustenta IoT controller for Windows PC running over node.js

## Set up

### Setup databases

You will need to create / modify the `devices` and `controllers` databases to add the functionality of this controller.
Just use the same *client_id* in the `controllers` database to connect to the broker.

### Setup PC

1. Make sure *NoPollSubscriber_NODEJS.js* is [up to date](https://github.com/roy-mdr/es-web-notify/blob/main/client/NoPollSubscriber_NODEJS.js).
1. Run *install.bat* (just double click) and follow instructions
1. If you are in the same network as the broker, change the pub and sub URLs in *config.json*. You will have to restart the services to update the connection (or just restart the PC)

> The dependency package *node-windows* is locked to beta-6. If you want to try if a new version is now working, just revert from `"node-windows": "1.0.0-beta.6"` to `"node-windows": "^1.0.0-beta.6"` in the *package.json* file.
> If you installed beta-6 and still is not working do the following:

1. Replace the library *node-windows* manually
    1. Delete the folder `node_modules\node-windows`
    1. Extract `res\node-windows.zip` to `node_modules\node-windows`

Now the service is installed and running

## Install Windows service (run as system)

If you didn't istalled NPM packages nor Windows service with *install.bat*, you can run `npm install` and then `node service-install.js`. Or just double click *install-npm.bat* and *install-service.bat* in that order.

> This instance will start listening when the system starts even if there is no user logged in.

> This instance will run under the user *system*, so it won't be able to run some user-specific cmd commands.

### Uninstall

1. Run `node service-install.js` or just double click *uninstall-service.bat*

## Install autorun (run as user)

If you didn't istalled the autorun with *install.bat*:

> This instance will only start listening when a user is logged in.

1. Run *install.bat* (just double click)
1. enter *NO* (N) for "Install NPM packages"
1. enter *YES* (Y) for "Install autorun for users"

It will create the auto-start command in registry.

### Uninstall

1. Run *uninstall.bat* (just double click) and follow instructions

> This will only uninstall the autorun and the protocol handler. The Windows service must be uninstalled independently.

## Debug

1. Run *test-indexjs.bat*

## To Do

- [x] Separate commands for run under user or system (atm some commands run duplicated)
- [ ] Organize files
- [ ] Make easier installers
- [ ] Make auto-update
- [ ] Won't disconnect connection when turned off or sleeped (possible solution with websockets or direct TCP)
- [ ] Will reconnect if PC delays more than 10 seconds to turn off or sleep (possible solution with websockets or direct TCP)
