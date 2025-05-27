const { Eureka } = require('eureka-js-client');

const client = new Eureka({
  instance: {
    app: 'AuthServiceAPI',
    instanceId: 'AuthServiceAPI:8083',
    hostName: process.env.HOSTNAME || 'AuthServiceAPI',
    ipAddr: '127.0.0.1',
    statusPageUrl: `http://${process.env.HOSTNAME || 'AuthServiceAPI'}:8083/info`,
    port: {
      '$': 8083,
      '@enabled': true,
    },
    vipAddress: 'AuthServiceAPI',
    dataCenterInfo: {
      '@class': 'com.netflix.appinfo.InstanceInfo$DefaultDataCenterInfo',
      name: 'MyOwn',
    },
  },
  eureka: {
    host: process.env.EUREKA_HOST || 'EurekaRegistry',
    port: process.env.EUREKA_PORT || 8761,
    servicePath: '/eureka/apps/',
  },
});

module.exports = client;