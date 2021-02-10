# Ballerina Azure Event Hubs Connector Samples:

1. Sending an event.

```ballerina
import ballerinax/azure_eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:PublisherClient eventHubClient = new (config);
   var result = eventHubClient->send("myhub", "eventData");
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/send_event.bal

2. Sending an event with broker properties and user properties.

```ballerina
import ballerinax/azure_eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:PublisherClient eventHubClient = new (config);
   map<string> brokerProps = {"CorrelationId": "32119834", "CorrelationId2": "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};

   var result = eventHubClient->send("myhub", "eventData", userProps, brokerProps);
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/send_event_with_broker_and_user_properties.bal

3. Sending an event with broker properties, user properties & partition key.
```ballerina
import ballerinax/azure_eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:PublisherClient eventHubClient = new (config);
   map<string> brokerProps = {PartitionKey: "groupName1", CorrelationId: "32119834";
   map<string> userProps = {Alert: "windy", warning: "true"};

   var result = eventHubClient->send("myhub", "data", userProps, brokerProps, partitionKey = "groupName");
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/send_event_with_partition_key.bal

4. Sending an event with broker properties, user properties & partition id.
```ballerina
import ballerinax/azure_eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:PublisherClient eventHubClient = new (config);
   map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};

   var result = eventHubClient->send("myhub", "data", userProps, brokerProps, partitionId = 1);
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/send_partition_event.bal

5. Sending a batch event.
```ballerina
import ballerinax/azure_eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:PublisherClient eventHubClient = new (config);
   map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};

    eventhub:BatchEvent batchEvent = {
        events: [
            {data: "Message1"},
            {data: "Message2", brokerProperties: brokerProps},
            {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
        ]
    };
    var result = eventHubClient->sendBatch("myhub", batchEvent);
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/send_batch_event.bal

6. Sending a batch event with partition key.
```ballerina
import ballerinax/azure_eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:PublisherClient eventHubClient = new (config);
   map<string> brokerProps = {PartitionKey: "groupName", CorrelationId: "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};

    eventhub:BatchEvent batchEvent = {
        events: [
            {data: "Message1"},
            {data: "Message2", brokerProperties: brokerProps},
            {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
        ]
    };
    var result = eventHubClient->sendBatch("myhub", batchEvent, partitionKey = "groupName");
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/send_batch_event_with_partition_key.bal

7. Sending a batch event to partition.
```ballerina
import ballerinax/azure_eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:PublisherClient eventHubClient = new (config);
   map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};

    eventhub:BatchEvent batchEvent = {
        events: [
            {data: "Message1"},
            {data: "Message2", brokerProperties: brokerProps},
            {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
        ]
    };
    var result = eventHubClient->sendBatch("myhub", batchEvent, partitionId = 1);
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/send_batch_event_to_partition.bal

8. Sending a batch event with publisher id
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:PublisherClient eventHubClient = new (config);
   map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};

    eventhub:BatchEvent batchEvent = {
        events: [
            {data: "Message1"},
            {data: "Message2", brokerProperties: brokerProps},
            {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
        ]
    };
    var result = eventHubClient->sendBatch("myhub", batchEvent, publisherId = "device-1");
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/send_batch_event_with_publisherId.bal

9. Create a new event hub
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:ManagementClient eventHubClient = new (config);
   var result = eventHubClient->createEventHub("myhub");
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/create_event_hub.bal

10. Get an event hub
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:ManagementClient eventHubClient = new (config);
   var result = eventHubClient->getEventHub("myhub");
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/get_event_hub.bal


11. Delete a event hub
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:ManagementClient eventHubClient = new (config);
   var result = eventHubClient->deleteEventHub("myhub");
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/delete_event_hub.bal

12. Create a new consumer group
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:ManagementClient eventHubClient = new (config);
   var result = eventHubClient->createConsumerGroup("myhub", "groupName");
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/create_consumer_group.bal

13. Get consumer group
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:ManagementClient eventHubClient = new (config);
   var result = eventHubClient->getConsumerGroup("myhub", "groupName");
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/get_consumer_group.bal


14. Delete a consumer group
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:ManagementClient eventHubClient = new (config);
   var result = eventHubClient->deleteConsumerGroup("myhub", "groupName");
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/delete_consumer_groups.bal
