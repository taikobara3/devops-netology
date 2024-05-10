local base = import './base.libsonnet';

 base {
   components +: {
     app +: {
       "replicaCount": 1,
       "deploymentName": "demoapp",
       "serviceName": "demoapp",
       "port": 8282,
       "targetPort": 80,
     },
  }
 }
