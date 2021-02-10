# Ballerina Azure Event Hubs Connector Samples:

## Event Hubs Service Operations
The Event Hub Ballerina Connector enables you to access the Event Hubs service to perform operations on event hubs. 
They have <namespaceName>.servicebus.windows.net/ in the request URI.

1. Send Event
This section shows how to use the ballerina connector to send events to an event hub. We must specify the event hub path 
and the event data in string/xml/json/byte[] array etc. formats as parameters to the send operation. This is the basic 
scenario of sending an event with string data “eventData” to the event hub path named “myhub”. It returns an eventhub 
error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/send_event.bal

```ballerina
import ballerinax/azure_eventhub;
import ballerina/config;
import ballerina/log;
 
public function main() {
   
   azure_eventhub:ClientEndpointConfiguration config = {
       sasKeyName: config:getAsString("SAS_KEY_NAME"),
       sasKey: config:getAsString("SAS_KEY"),
       resourceUri: config:getAsString("RESOURCE_URI")
   };
   azure_eventhub:PublisherClient publisherClient = new (config);
  
   var result = publisherClient->send("myhub", "eventData");
   if (result is error) {
       
 log:printError(msg = result.message());
   } else {
       log:print("Successful!");
   }
}
```

2. Send an event with broker properties and user properties
This section shows how to use the ballerina connector to send events to an event hub with specified broker properties 
and user properties. We must specify the event hub path and the event data in string/xml/json/byte[] array etc. 
formats as parameters to the send operation. Additionally we can specify user properties and broker properties as a map 
which is optional. This is the basic scenario of sending an event with string data “eventData” to the event hub path 
named “myhub” with optional broker properties and user properties. It returns an eventhub error if the operation is 
unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/send_event_with_broker_and_user_properties.bal

```ballerina
import ballerinax/azure_eventhub;
import ballerina/config;
import ballerina/log;
 
public function main() {
   
   azure_eventhub:ClientEndpointConfiguration config = {
       sasKeyName: config:getAsString("SAS_KEY_NAME"),
       sasKey: config:getAsString("SAS_KEY"),
       resourceUri: config:getAsString("RESOURCE_URI")
   };
   azure_eventhub:PublisherClient publisherClient = new (config);
 
   map<string> brokerProps = {"CorrelationId": "32119834", "CorrelationId2": "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};
 
   var result = publisherClient->send("myhub", "eventData", userProps, brokerProps);
   if (result is error) {
       
 log:printError(result.message());
   } else {
       log:print("Successful!");
   }
}
```

3. Send event with partition key
This section shows how to use the ballerina connector to send events to an event hub with broker properties, 
user properties and specified partition ID. We must specify the event hub path and the event data in 
string/xml/json/byte[] array etc. formats as parameters to the send operation. Additionally we can specify user 
properties and broker properties as a map which is optional. We can also specify the partition key to send the event 
data to a specific partition of the event hub. This is the basic scenario of sending an event with string data 
“eventData” to the event hub path named “myhub” with optional broker properties and user properties. It sends the 
event data with the partition key “groupname” to a specific partition in the eventhub named “myhub”. It returns 
an eventhub error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/send_event_with_partition_key.bal


```ballerina
import ballerinax/azure_eventhub;
import ballerina/config;
import ballerina/log;
 
public function main() {
   
   azure_eventhub:ClientEndpointConfiguration config = {
       sasKeyName: config:getAsString("SAS_KEY_NAME"),
       sasKey: config:getAsString("SAS_KEY"),
       resourceUri: config:getAsString("RESOURCE_URI")
   };
   azure_eventhub:PublisherClient publisherClient = new (config);
 
   map<string> brokerProps = {PartitionKey: "groupName1", CorrelationId: "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};
 
   // partition key used as the parameter is prioritized over the partition key provided in the brokerProperties
   var result = publisherClient->send("myhub", "eventData", userProps, brokerProps, partitionKey = "groupName");
   if (result is error) {
       
 log:printError(result.message());
   } else {
       log:print("Successful!");
   }
}
```

4. Send partition event
This section shows how to use the ballerina connector to send events to an event hub with broker properties, 
user properties and specified partition ID. We must specify the event hub path and the event data in 
string/xml/json/byte[] array etc. formats as parameters to the send operation. Additionally we can specify user 
properties and broker properties as a map which is optional. We can also specify the specific partition of the event hub 
to send the event data. This is the basic scenario of sending an event with string data “eventData” to the event hub 
path named “myhub” with optional broker properties and user properties. It sends the event data to the partition 1 in 
the eventhub named “myhub”. It returns an eventhub error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/send_partition_event.bal

```ballerina
import ballerinax/azure_eventhub;
import ballerina/config;
import ballerina/log;
 
public function main() {
   
   azure_eventhub:ClientEndpointConfiguration config = {
       sasKeyName: config:getAsString("SAS_KEY_NAME"),
       sasKey: config:getAsString("SAS_KEY"),
       resourceUri: config:getAsString("RESOURCE_URI")
   };
   azure_eventhub:PublisherClient publisherClient = new (config);
 
   map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};
 
   var result = publisherClient->send("myhub", "eventData", userProps, brokerProps, partitionId = 1);
   if (result is error) {
       
 log:printError(result.message());
   } else {
       log:print("Successful!");
   }
}
```
Note:
You can specify the event hub path and the event data as parameters of the send method.
This operation will return a ballerina error if the operation failed.

5. Send batch events
This section shows how to use the ballerina connector to send batch events to an event hub. We must specify the event 
hub path and the event data in string/xml/json/byte[] array etc. formats as parameters to the send operation. 
Additionally we can specify user properties and broker properties as a map which is optional. Events are specified as 
an array of BatchMessage records and each BatchMessage includes event data, and optional user properties and broker 
properties. This is the basic scenario of sending an event with batch event to the event hub path named “myhub” with 
BatchEvent. It returns an eventhub error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/send_batch_event.bal

```ballerina
import ballerinax/azure_eventhub;
import ballerina/config;
import ballerina/log;
 
public function main() {
   
   azure_eventhub:ClientEndpointConfiguration config = {
       sasKeyName: config:getAsString("SAS_KEY_NAME"),
       sasKey: config:getAsString("SAS_KEY"),
       resourceUri: config:getAsString("RESOURCE_URI")
   };
   azure_eventhub:PublisherClient publisherClient = new (config);
 
   map<string> brokerProps = {PartitionKey: "groupName", CorrelationId: "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};
 
   azure_eventhub:BatchEvent batchEvent = {
       events: [
           {data: "Message1"},
           {data: "Message2", brokerProperties: brokerProps},
           {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
       ]
   };
   var result = publisherClient->sendBatch("myhub", batchEvent, partitionKey = "groupName");
   if (result is error) {
       
 log:printError(result.message());
   } else {
       log:print("Successful!");
   }
}
```
Note:
You can specify the event hub path, the batch event of record type BatchEvent and publisher ID as parameters of the 
send method.
This operation will return a ballerina error if the operation failed.

6. Send batch event with partition key
This section shows how to use the ballerina connector to send batch events to an event hub with broker properties, 
user properties and specified partition key. We must specify the event hub path and the event data in 
string/xml/json/byte[] array etc. formats as parameters to the send operation. Additionally we can specify user 
properties and broker properties as a map which is optional. Events are specified as an array of BatchMessage records 
and each BatchMessage includes event data, and optional user properties and broker properties. This is the basic 
scenario of sending an event with batch event to the event hub path named “myhub” with BatchEvent and partition key as 
“groupName”. It returns an eventhub error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/send_batch_event_with_partition_key.bal

```ballerina
import ballerinax/azure_eventhub;
import ballerina/config;
import ballerina/log;
 
public function main() {
   
   azure_eventhub:ClientEndpointConfiguration config = {
       sasKeyName: config:getAsString("SAS_KEY_NAME"),
       sasKey: config:getAsString("SAS_KEY"),
       resourceUri: config:getAsString("RESOURCE_URI")
   };
   azure_eventhub:PublisherClient publisherClient = new (config);
 
   map<string> brokerProps = {PartitionKey: "groupName", CorrelationId: "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};
 
   azure_eventhub:BatchEvent batchEvent = {
       events: [
           {data: "Message1"},
           {data: "Message2", brokerProperties: brokerProps},
           {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
       ]
   };
   var result = publisherClient->sendBatch("myhub", batchEvent, partitionKey = "groupName");
   if (result is error) {
       
 log:printError(result.message());
   } else {
       log:print("Successful!");
   }
}
```
Note:
You can specify the event hub path, the batch event of record type BatchEvent and partition key as parameters of the 
send method.
This operation will return a ballerina error if the operation failed.


7. Send batch event with publisher ID
This section shows how to use the ballerina connector to send batch events to an event hub with broker properties, 
user properties and specified publisher ID. We must specify the event hub path and the event data in 
string/xml/json/byte[] array etc. formats as parameters to the send operation. Additionally we can specify user 
properties and broker properties as a map which is optional. We can also include publisher name as publisher ID. 
Events are specified as an array of BatchMessage records and each BatchMessage includes event data, and optional 
user properties and broker properties. This is the basic scenario of sending an event with batch event to the event hub 
path named “myhub” with BatchEvent and publisher ID as “device-1”. It returns an eventhub error if the operation is 
unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/send_batch_event_with_publisherId.bal

```ballerina
import ballerinax/azure_eventhub;
import ballerina/config;
import ballerina/log;
 
public function main() {
   
   azure_eventhub:ClientEndpointConfiguration config = {
       sasKeyName: config:getAsString("SAS_KEY_NAME"),
       sasKey: config:getAsString("SAS_KEY"),
       resourceUri: config:getAsString("RESOURCE_URI")
   };
   azure_eventhub:PublisherClient publisherClient = new (config);
 
   map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};
 
   azure_eventhub:BatchEvent batchEvent = {
       events: [
           {data: "Message1"},
           {data: "Message2", brokerProperties: brokerProps},
           {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
       ]
   };
   var result = publisherClient->sendBatch("myhub", batchEvent, publisherId = "device-1");
   if (result is error) {
       
 log:printError(result.message());
   } else {
       log:print("Successful!");
   }
}
```
Note:
You can specify the event hub path, the batch event of record type BatchEvent and publisher ID as parameters of the 
send method.
This operation will return a ballerina error if the operation failed.

## Event Hubs Management Operations

The Event Hub Ballerina Connector enables you to perform management operations on Event Hubs.

1. Create a new event hub
This section shows how to use the ballerina connector to create a new event hub. We must specify the event hub name as 
a parameter to create a new event hub. This is the basic scenario of creating an event hub named “myhub”. It returns 
an eventhub error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/create_event_hub.bal

```ballerina
 
import ballerinax/azure_eventhub;
import ballerina/config;
import ballerina/log;
 
public function main() {
   
   azure_eventhub:ClientEndpointConfiguration config = {
       sasKeyName: config:getAsString("SAS_KEY_NAME"),
       sasKey: config:getAsString("SAS_KEY"),
       resourceUri: config:getAsString("RESOURCE_URI")
   };
   azure_eventhub:ManagementClient managementClient = new (config);
 
   var result = managementClient->createEventHub("myhub");
   if (result is error) {
       log:printError(result.message());
   }
   if (result is xml) {
       
 log:print(result.toString());
       log:print("Successful!");
   }
}
```

2. Get an event hub
This section shows how to use the ballerina connector to get all the metadata associated with the specified event hub. 
We must specify the event hub name as a parameter to get all the metadata associated with the specified event hub. 
This is the basic scenario of getting all the metadata associated with the event hub named “myhub”. It returns 
an eventhub error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/get_event_hub.bal

```ballerina
import ballerinax/azure_eventhub;
import ballerina/config;
import ballerina/log;
 
public function main() {
   
   azure_eventhub:ClientEndpointConfiguration config = {
       sasKeyName: config:getAsString("SAS_KEY_NAME"),
       sasKey: config:getAsString("SAS_KEY"),
       resourceUri: config:getAsString("RESOURCE_URI")
   };
   azure_eventhub:ManagementClient managementClient = new (config);
 
   var result = managementClient->getEventHub("myhub");
   if (result is error) {
       log:printError(result.message());
   }
   if (result is xml) {
       
 log:print(result.toString());
       log:print("Successful!");
   }
}
```

3. Update an event hub
This section shows how to use the ballerina connector to update the properties of an event hub. We must specify the 
event hub name as a parameter and EventHubDecsriptionToUpdate record with message retention in days property to update 
the properties of the event hub. This is the basic scenario of updating the properties associated with the event hub 
named “myhub”. It returns an eventhub error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/update_event_hub.bal

```ballerina
import ballerinax/azure_eventhub;
import ballerina/config;
import ballerina/log;
 
public function main() {
   
   azure_eventhub:ClientEndpointConfiguration config = {
       sasKeyName: config:getAsString("SAS_KEY_NAME"),
       sasKey: config:getAsString("SAS_KEY"),
       resourceUri: config:getAsString("RESOURCE_URI")
   };
   azure_eventhub:ManagementClient managementClient = new (config);
 
   azure_eventhub:EventHubDescriptionToUpdate eventHubDescriptionToUpdate = {
       MessageRetentionInDays: 5
   };
   var result = managementClient->updateEventHub("myhub", eventHubDescriptionToUpdate);
   if (result is error) {
       log:printError(result.message());
   }
   if (result is xml) {
       
 log:print(result.toString());
       log:print("Successful!");
   }
}
```

4. List Event Hubs
This section shows how to use the ballerina connector to get all the metadata associated with the event hubs in a 
specified namespace. We must specify the event hub name as a parameter to get all the metadata associated with the 
specified event hubs in the namespace. This is the basic scenario of getting all the metadata associated with the 
event hubs in the specified namespace. It returns an eventhub error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/list_event_hubs.bal

```ballerina
import ballerinax/azure_eventhub;
import ballerina/config;
import ballerina/log;
 
public function main() {
   
   azure_eventhub:ClientEndpointConfiguration config = {
       sasKeyName: config:getAsString("SAS_KEY_NAME"),
       sasKey: config:getAsString("SAS_KEY"),
       resourceUri: config:getAsString("RESOURCE_URI")
   };
   azure_eventhub:ManagementClient managementClient = new (config);
 
   var result = managementClient->listEventHubs();
   if (result is error) {
       log:printError(result.message());
   }
   if (result is xml) {
       
 log:print(result.toString());
       log:print("listReceived");
   }
}
```

5. Delete an event hub
This section shows how to use the ballerina connector to delete an event hub. We must specify the event hub name as a 
parameter to delete an event hub. This is the basic scenario of deleting an event hub named “myhub”. It returns an 
eventhub error if the operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/delete_event_hub.bal

```ballerina
import ballerinax/azure_eventhub;
import ballerina/config;
import ballerina/log;
 
public function main() {
   
   azure_eventhub:ClientEndpointConfiguration config = {
       sasKeyName: config:getAsString("SAS_KEY_NAME"),
       sasKey: config:getAsString("SAS_KEY"),
       resourceUri: config:getAsString("RESOURCE_URI")
   };
   azure_eventhub:ManagementClient managementClient= new (config);
 
   var result = managementClient->deleteEventHub("myhub");
   if (result is error) {
       
 log:printError(result.message());
   } else {
       log:print("Successful!");
   }
}
```

6. Create a new consumer group
This section shows how to use the ballerina connector to create a new consumer group for an event hub. We must specify 
the consumer group name as a parameter to create a new consumer group for an event hub. This is the basic scenario of 
creating a consumer group named “groupname” in the event hub named “myhub”. It returns an eventhub error if the 
operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/create_consumer_group.bal

```ballerina
import ballerinax/azure_eventhub;
import ballerina/config;
import ballerina/log;
 
public function main() {
   
   azure_eventhub:ClientEndpointConfiguration config = {
       sasKeyName: config:getAsString("SAS_KEY_NAME"),
       sasKey: config:getAsString("SAS_KEY"),
       resourceUri: config:getAsString("RESOURCE_URI")
   };
   azure_eventhub:ManagementClient managementClient = new (config);
 
   var result = managementClient->createConsumerGroup("myhub", "groupname");
   if (result is error) {
       log:printError(result.message());
   }
   if (result is xml) {
       
 log:print(result.toString());
       log:print("successful");
   }
}
```
Note:
You can specify the event hub path and consumer group name as parameters of the createConsumerGroup method.
This operation will return a ballerina error if the operation failed.

7. Get consumer group
This section shows how to use the ballerina connector to get all the metadata associated with the specified consumer 
group. We must specify the consumer group name as a parameter to  get all the metadata associated with the specified 
consumer group in the given event hub. This is the basic scenario of getting all the metadata associated with the 
specified consumer group named “groupname” in the event hub named “myhub”. It returns an eventhub error if the 
operation is unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/get_consumer_group.bal

```ballerina
import ballerinax/azure_eventhub;
import ballerina/config;
import ballerina/log;
 
public function main() {
   
   azure_eventhub:ClientEndpointConfiguration config = {
       sasKeyName: config:getAsString("SAS_KEY_NAME"),
       sasKey: config:getAsString("SAS_KEY"),
       resourceUri: config:getAsString("RESOURCE_URI")
   };
   azure_eventhub:ManagementClient managementClient = new (config);
 
   var result = managementClient->getConsumerGroup("myhub", "groupname");
   if (result is error) {
       log:printError(result.message());
   }
   if (result is xml) {
       
 log:print(result.toString());
       log:print("successful");
   }
}
```
Note:
You can specify the event hub path and consumer group name as parameters of the getConsumerGroup method.
This operation will return a ballerina error if the operation failed.

8. List consumer groups
This section shows how to use the ballerina connector to get all the consumer groups associated with the specified event 
hub. We must specify the event hub name as a parameter to  get all the metadata associated with all the consumer groups 
associated with the specified event hub. This is the basic scenario of get all the metadata associated with all the 
consumer groups associated with the specified event hub named “myhub”. It returns an eventhub error if the operation is 
unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/list_consumer_groups.bal

```ballerina
import ballerinax/azure_eventhub;
import ballerina/config;
import ballerina/log;
 
public function main() {
   
   azure_eventhub:ClientEndpointConfiguration config = {
       sasKeyName: config:getAsString("SAS_KEY_NAME"),
       sasKey: config:getAsString("SAS_KEY"),
       resourceUri: config:getAsString("RESOURCE_URI")
   };
   azure_eventhub:ManagementClient managementClient = new (config);
 
   var result = managementClient->listConsumerGroups("myhub");
   if (result is error) {
       log:printError(result.message());
   }
   if (result is xml) {
       
 log:print(result.toString());
       log:print("successful");
   }
}
```
Note:
You can specify the event hub path as a parameter of the listConsumerGroups method.
This operation will return a ballerina error if the operation failed.

9. List partitions
This section shows how to use the ballerina connector to get all the metadata associated with the partitions of a 
specified consumer group.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/list_partitions.bal

```ballerina
import ballerinax/azure_eventhub;
import ballerina/config;
import ballerina/log;
 
public function main() {
   
   azure_eventhub:ClientEndpointConfiguration config = {
       sasKeyName: config:getAsString("SAS_KEY_NAME"),
       sasKey: config:getAsString("SAS_KEY"),
       resourceUri: config:getAsString("RESOURCE_URI")
   };
   azure_eventhub:ManagementClient managementClient = new (config);
 
   var result = managementClient->listPartitions("myhub", "groupname");
   if (result is error) {
       log:printError(result.message());
   }
   if (result is xml) {
       
 log:print(result.toString());
       log:print("successful");
   }
}
```
Note:
You can specify the event hub path and consumer group name as parameters of the listPartitions method.
This operation will return a ballerina error if the operation failed.

10. Get partition
This section shows how to use the ballerina connector to get the metadata associated with the specified partition of a 
consumer group.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/get_partition.bal

```ballerina
import ballerinax/azure_eventhub;
import ballerina/config;
import ballerina/log;
 
public function main() {
   
   azure_eventhub:ClientEndpointConfiguration config = {
       sasKeyName: config:getAsString("SAS_KEY_NAME"),
       sasKey: config:getAsString("SAS_KEY"),
       resourceUri: config:getAsString("RESOURCE_URI")
   };
   azure_eventhub:ManagementClient managementClient = new (config);
 
   var result = managementClient->getPartition("myhub", "groupname", 1);
   if (result is error) {
       log:printError(result.message());
   }
   if (result is xml) {
       
 log:print(result.toString());
       log:print("successful");
   }
}
```
Note:
You can specify the event hub path, consumer group name and partition ID as parameters of the getPartition method.
This operation will return a ballerina error if the operation failed.


11. Delete a consumer group
This section shows how to use the ballerina connector to delete a consumer group from an event hub. We must specify the 
consumer group name as a parameter to delete a consumer group from an event hub. This is the basic scenario of deleting 
a consumer group named “groupname” in the event hub named “myhub”. It returns an eventhub error if the operation is 
unsuccessful.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/delete_consumer_groups.bal

```ballerina
import ballerinax/azure_eventhub;
import ballerina/config;
import ballerina/log;
 
public function main() {
   
   azure_eventhub:ClientEndpointConfiguration config = {
       sasKeyName: config:getAsString("SAS_KEY_NAME"),
       sasKey: config:getAsString("SAS_KEY"),
       resourceUri: config:getAsString("RESOURCE_URI")
   };
   azure_eventhub:ManagementClient managementClient = new (config);
 
   var result = managementClient->deleteConsumerGroup("myhub","groupname");
   if (result is error) {
       log:printError(result.message());
   }
   if (result is ()) {
       log:print("successful");
   }
}
```
Note:
You can specify the event hub path and consumer group name as parameters of the createConsumerGroup method.
This operation will return a ballerina error if the operation failed.

## Publisher Policy Operations

The Event Hub Ballerina Connector enables you to perform publisher policy operations on event hubs.

1. Get Revoked Publishers
This section shows how to use the ballerina connector to retrieve all revoked publishers within the specified event hub.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/get_revoked_publishers.bal

```ballerina
import ballerinax/azure_eventhub;
import ballerina/config;
import ballerina/log;
 
public function main() {
   
   azure_eventhub:ClientEndpointConfiguration config = {
       sasKeyName: config:getAsString("SAS_KEY_NAME"),
       sasKey: config:getAsString("SAS_KEY"),
       resourceUri: config:getAsString("RESOURCE_URI")
   };
   azure_eventhub:PublisherClient publisherClient = new (config);
 
   var result = publisherClient->getRevokedPublishers("myeventhub");
   if (result is error) {
       log:printError(result.message());
   }
   if (result is xml) {
       log:print("listReceived");
       
 log:print(result.toString());
       log:print("Successful!");
   }
}
```

2. Revoke Publisher
This section shows how to use the ballerina connector to revoke a publisher so that a revoked publisher may encounter 
errors when sending events to the event hub.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/revoke_publisher.bal

```ballerina
import ballerinax/azure.eventhub as eventhub;
 
public function main() {
  eventhub:ClientEndpointConfiguration config = {
      sasKeyName: "<sas_key_name>",
      sasKey: "<sas_key>",
      resourceUri: "<resource_uri>"
  };
  eventhub:Client c = <eventhub:Client>new eventhub:Client(config);
  var b = c->revokePublisher("myeventhub", "device-1");
}
```

3. Resume Publisher
This section shows how to use the ballerina connector to resume a revoked publisher so that the publisher can resume 
sending events to the event hub.

Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/resume_publisher.bal

```ballerina
import ballerinax/azure_eventhub;
import ballerina/config;
import ballerina/log;
 
public function main() {
   
   azure_eventhub:ClientEndpointConfiguration config = {
       sasKeyName: config:getAsString("SAS_KEY_NAME"),
       sasKey: config:getAsString("SAS_KEY"),
       resourceUri: config:getAsString("RESOURCE_URI")
   };
   azure_eventhub:PublisherClient publisherClient = new (config);
 
   var result = publisherClient->resumePublisher("myeventhub", "device-1");
   if (result is error) {
       log:printError(result.message());
   }
   if (result is ()) {
       log:print("successful");
   }
}
```
