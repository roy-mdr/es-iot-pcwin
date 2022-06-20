var Service = require('node-windows').Service;

// Create a new service object
var svc = new Service({
  name:'ES_svcwkr',
  description: 'Estudio Sustenta service worker',
  script: 'D:\\portables\\laragon\\www\\rt-svcwkr\\index.js',
  nodeOptions: [
    '--harmony',
    '--max_old_space_size=512'
  ]
  //, workingDirectory: '...'
  //, allowServiceLogon: true
});

// Listen for the "install" event, which indicates the
// process is available as a service.
svc.on('install',function(){
  svc.start();
});

svc.uninstall();