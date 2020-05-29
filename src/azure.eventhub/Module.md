Azure EventHub Connector

# Module Overview

Azure Event Hubs is a highly scalable data ingress service that ingests millions of events per second so that you can process and analyze the massive amounts of data produced by your connected devices and applications. Once data is collected into an Event Hub, it can be transformed and stored using any real-time analytics provider or batching/storage adapters.

The connector will only be focusing on sending events to the event hub. The event hub connector will invoke the REST APIs exposed via the Azure Event Hub. https://docs.microsoft.com/en-us/rest/api/eventhub/. 

The REST APIs fall into the following categories:

- Azure Resource Manager: 
  APIs that perform resource manager operations, and have /providers/Microsoft.EventHub/ as part of the request URI.

- Event Hubs service: 
  APIs that enable operations directly on the Event Hubs service, and have <namespaceName>.servicebus.windows.net/ in the request URI. The Event Hubs service API is focused on this implementation. 

## Samples:

1. Sending an event.

```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "admin",
       sasKey: "Ct9V2xF9X8ulLxYPiasINsoZSZSVPTzpeKKocV4XBHE=",
       resourceUri: "c2cnamespace.servicebus.windows.net/myhub"
   };
   eventhub:Client c = <eventhub:Client>new eventhub:Client(config);
   var b = c->send("eventData");
}
```

2. Sending an event with broker properties and user properties.

```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "admin",
       sasKey: "Ct9V2xF9X8ulLxYPiasINsoZSZSVPTzpeKKocV4XBHE=",
       resourceUri: "c2cnamespace.servicebus.windows.net/myhub"
   };
   eventhub:Client c = <eventhub:Client>new eventhub:Client(config);
   map<string> brokerProps = {"CorrelationId": "32119834", "CorrelationId2": "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};

   var b = c->send("eventData", userProps, brokerProps);
}
```

3. Sending an event with broker properties, user properties & partition id.
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "admin",
       sasKey: "Ct9V2xF9X8ulLxYPiasINsoZSZSVPTzpeKKocV4XBHE=",
       resourceUri: "c2cnamespace.servicebus.windows.net/myhub"
   };
   eventhub:Client c = <eventhub:Client>new eventhub:Client(config);
   map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};

   var b = c->send("data", userProps, brokerProps, partitionId=1);
}
```

4. Sending a batch event.
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "admin",
       sasKey: "Ct9V2xF9X8ulLxYPiasINsoZSZSVPTzpeKKocV4XBHE=",
       resourceUri: "c2cnamespace.servicebus.windows.net/myhub"
   };
   eventhub:Client c = <eventhub:Client>new eventhub:Client(config);
   map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};

    eventhub:BatchEvent batchEvent = {
        events: [
            {data: "Message1"},
            {data: "Message2", brokerProperties: brokerProps},
            {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
        ]
    };
    var b = c->sendBatch(batchEvent);
}
```

5. Sending a batch event to partition.
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "admin",
       sasKey: "Ct9V2xF9X8ulLxYPiasINsoZSZSVPTzpeKKocV4XBHE=",
       resourceUri: "c2cnamespace.servicebus.windows.net/myhub"
   };
   eventhub:Client c = <eventhub:Client>new eventhub:Client(config);
   map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};

    eventhub:BatchEvent batchEvent = {
        events: [
            {data: "Message1"},
            {data: "Message2", brokerProperties: brokerProps},
            {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
        ]
    };
    var b = c->sendBatch(batchEvent, partitionId=1);
}
```

6. Sending a batch event to partition with publisher id
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "admin",
       sasKey: "Ct9V2xF9X8ulLxYPiasINsoZSZSVPTzpeKKocV4XBHE=",
       resourceUri: "c2cnamespace.servicebus.windows.net/myhub"
   };
   eventhub:Client c = <eventhub:Client>new eventhub:Client(config);
   map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};

    eventhub:BatchEvent batchEvent = {
        events: [
            {data: "Message1"},
            {data: "Message2", brokerProperties: brokerProps},
            {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
        ]
    };
    var b = c->sendBatch(batchEvent, partitionId=1, publisherId="device-1");
}
```
