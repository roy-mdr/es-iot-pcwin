# es-iot-pcwin

Estudio Sustenta IoT controller for Windows PC running over node.js

## Set up

You will need to create / modify the `devices` and `controllers` databases to add the functionality of this controller.
Just use the same *client_id* in the `controllers` database to connect to the broker.

## Install (run as system)

> This instance will start listening when the system starts even if there is no user logged in.

> This instance will run under the user *system*, so it won't be able to run some user-specific cmd commands.
> To fix this follow the instructions of *Install (run as user)*

1. Run `npm install`
1. Make sure [*NoPollSubscriber_NODEJS.js*](https://github.com/roy-mdr/es-web-notify/blob/main/client/NoPollSubscriber_NODEJS.js) is up to date.
1. Replace the library *node-windows* manually (new one does not work)
    1. Delete the folder `node_modules\node-windows`
    1. Extract `res\node-windows.zip` to `node_modules\node-windows`
1. Modify *config.json* with a custom *client_id* (and if necesary the pub and sub servers)
1. Modify *service-install.js* and *service-uninstall.js* with the path pointing to *index.js*
1. Run `node service-install.js`

Now the service is installed and running

### Debug

1. Modify and run `test-indexjs.bat`

### Uninstall

1. Run `node service-install.js`

## Install (run as user)

> This instance will only start listening when a user is logged in.

1. Run *install.bat* (just double click) and follow instructions

It will create the auto-start command in registry.

### Uninstall

1. Run *uninstall.bat* (just double click) and follow instructions

## To Do

- [ ] Separate commands for run under user or system (atm some commands run duplicated)
- [ ] Organize files
- [ ] Make easier installers
- [ ] Make auto-update
- [ ] Won't disconnect connection when turned off or sleeped (possible solution with websockets or direct TCP)
- [ ] Will reconnect if PC delays more than 10 seconds to turn off or sleep (possible solution with websockets or direct TCP)
