Azure EventHub Connector

# Module Overview

Azure Event Hubs is a highly scalable data ingress service that ingests millions of events per second so that you can process and analyze the massive amounts of data produced by your connected devices and applications. Once data is collected into an Event Hub, it can be transformed and stored using any real-time analytics provider or batching/storage adapters.

The connector will only be focusing on sending events to the event hub. The event hub connector will invoke the REST APIs exposed via the Azure Event Hub. https://docs.microsoft.com/en-us/rest/api/eventhub/. 

The REST APIs fall into the following categories:

- Azure Resource Manager: 
  APIs that perform resource manager operations, and have /providers/Microsoft.EventHub/ as part of the request URI.

- Event Hubs service: 
  APIs that enable operations directly on the Event Hubs service, and have <namespaceName>.servicebus.windows.net/ in the request URI. The Event Hubs service API is focused on this implementation. 

## Compatibility
|                     |    Version          |
|:-------------------:|:-------------------:|
| Ballerina Language  | swan-lake-preview8  |


## Samples:

1. Sending an event.

```ballerina
import ballerinax/azure_eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:Client c = new (config);
   var b = c->send("myhub", "eventData");
}
```

2. Sending an event with broker properties and user properties.

```ballerina
import ballerinax/azure_eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:Client c = new (config);
   map<string> brokerProps = {"CorrelationId": "32119834", "CorrelationId2": "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};

   var b = c->send("myhub", "eventData", userProps, brokerProps);
}
```

3. Sending an event with broker properties, user properties & partition id.
```ballerina
import ballerinax/azure_eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:Client c = new (config);
   map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};

   var b = c->send("myhub", "data", userProps, brokerProps, partitionId=1);
}
```

4. Sending a batch event.
```ballerina
import ballerinax/azure_eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:Client c = new (config);
   map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};

    eventhub:BatchEvent batchEvent = {
        events: [
            {data: "Message1"},
            {data: "Message2", brokerProperties: brokerProps},
            {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
        ]
    };
    var b = c->sendBatch("myhub", batchEvent);
}
```

5. Sending a batch event to partition.
```ballerina
import ballerinax/azure_eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:Client c = new (config);
   map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};

    eventhub:BatchEvent batchEvent = {
        events: [
            {data: "Message1"},
            {data: "Message2", brokerProperties: brokerProps},
            {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
        ]
    };
    var b = c->sendBatch("myhub", batchEvent, partitionId=1);
}
```

6. Sending a batch event with publisher id
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:Client c = new (config);
   map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};

    eventhub:BatchEvent batchEvent = {
        events: [
            {data: "Message1"},
            {data: "Message2", brokerProperties: brokerProps},
            {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
        ]
    };
    var b = c->sendBatch("myhub", batchEvent, publisherId="device-1");
}
```

7. Create a new event hub
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:Client c = new (config);
   var b = c->createEventHub("myhub");
}
```

8. Get an event hub
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:Client c = new (config);
   var b = c->getEventHub("myhub");
}
```

9. Delete a event hub
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:Client c = new (config);
   var b = c->deleteEventHub("myhub");
}
```

10. Create a new consumer group
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:Client c = new (config);
   var b = c->createConsumerGroup("myhub", "groupName");
}
```

11. Get consumer group
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:Client c = new (config);
   var b = c->getConsumerGroup("myhub", "groupName");
}
```

12. Delete a consumer group
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:Client c = new (config);
   var b = c->deleteConsumerGroup("myhub", "groupName");
}
```
